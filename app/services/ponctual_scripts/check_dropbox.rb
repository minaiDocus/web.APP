class PonctualScripts::CheckDropbox < PonctualScripts::PonctualScript
  ROOT_FOLDER = '/exportation vers iDocus'.freeze
  ERROR_LISTS = {
                  already_exist: 'fichier déjà importé sur iDocus',
                  invalid_period: 'période invalide',
                  journal_unknown: 'journal invalide',
                  invalid_file_extension: 'extension invalide',
                  file_size_is_too_big: 'fichier trop volumineux',
                  pages_number_is_too_high: 'nombre de page trop important',
                  # file_is_corrupted_or_protected: 'Votre document est en-cours de traitement',
                  # real_corrupted_document: 'fichier corrompu ou protégé par mdp',
                  unprocessable: 'erreur fichier non valide pour iDocus'
                }.freeze
  def self.execute
    new().execute
  end

  def initialize
    collab = User.find_by_code('AZC%AZC')
    # collab = User.find_by_code('IDOC%MNA') if Rails.env != 'production'

    @dropbox = collab.external_file_storage.dropbox_basic

    @current_cursor      = @dropbox.delta_cursor
    @current_path_prefix = @dropbox.delta_path_prefix

    if @current_path_prefix != ROOT_FOLDER
      @current_cursor = nil
      @current_path_prefix = ROOT_FOLDER
    end

    @initial_cursor = @current_cursor.try(:dup)
  end 

  def execute(for_all=true)
    if @dropbox.is_used? && @dropbox.is_configured? && customers.any?
      check_for_all
      # if (for_all || @dropbox.need_to_check_for_all?) && @dropbox.import_folder_paths.present? && @dropbox.import_folder_paths.any?
        # check_for_all
      # else

        # checked_at = Time.now
        # has_more = true

        # initialize_folders if @current_cursor.nil?

        # while has_more && @current_cursor
        #   retryable = true
        #   begin
        #     result = client.list_folder_continue(@current_cursor)
        #   rescue DropboxApi::Errors::WriteError => e
        #     if e.message.match(/path\/not_found\//) && retryable
        #       initialize_folders
        #       retryable = false
        #       retry
        #     else
        #       raise
        #     end
        #   end

        #   result.entries.each do |entry|
        #     process_entry entry
        #   end

        #   has_more = result.has_more?
        #   @current_cursor = result.cursor
        # end

        # update_folders

        # @dropbox.update(
        #   delta_cursor:        @current_cursor,
        #   delta_path_prefix:   @current_path_prefix,
        #   import_folder_paths: needed_folders,
        #   checked_at:          checked_at
        # )
      # end
    end    
  end

  def client
    @client ||= FileImport::Dropbox::Client.new(DropboxApi::Client.new(@dropbox.access_token))
  end

  def user
    @user ||= @dropbox.user.collaborator? ? Collaborator.new(@dropbox.user) : @dropbox.user
  end

  def customers
    if @customers
      @customers
    else
      @customers = if user.is_prescriber && user.organization
        user.all_customers.active.order(code: :asc)
      else
        User.where(id: ([user.id] + user.accounts.map(&:id))).order(code: :asc)
      end
      @customers = @customers.select { |c| c.authorized_upload? }
    end
  end

  def needed_folders
    if @needed_folders
      @needed_folders
    else
      @needed_folders = []
      period_types = ['période actuelle', 'période précédente'].freeze

      customers.each do |customer|
        base_path = Pathname.new ROOT_FOLDER
        if user.collaborator?
          code = user.memberships.find { |m| m.organization_id == customer.organization_id }.code
          base_path = base_path.join code
        end
        customer_path = base_path.join "#{customer.code} - #{customer.company.gsub(/[\\\/\:\?\*\"\|&]/, '').strip}"
        account_book_type_names = customer.account_book_types.order(name: :asc).map(&:name)
        period_types.each do |period_type|
          period_path = customer_path.join period_type
          account_book_type_names.each do |account_book_type_name|
            @needed_folders << period_path.join(account_book_type_name).to_s
          end
        end
      end

      @needed_folders
    end
  end

  def folders
    if @folders
      @folders
    else
      new_paths    = needed_folders - @dropbox.import_folder_paths
      unused_paths = @dropbox.import_folder_paths - needed_folders

      @folders = needed_folders.map do |path|
        if new_paths.include?(path)
          FileImport::Dropbox::Folder.new(path, false)
        else
          FileImport::Dropbox::Folder.new(path, @initial_cursor.present?)
        end
      end
      @folders += unused_paths.map do |path|
        FileImport::Dropbox::Folder.new(path, nil)
      end

      @folders
    end
  end

  def initialize_folders
    @dropbox.import_folder_paths = []
    @folders = nil
    update_folders
    begin
      @current_cursor = client.list_folder_get_latest_cursor(path: @current_path_prefix, recursive: true).cursor
    rescue DropboxApi::Errors::NotFoundError => e
      raise unless e.message.match(/path\/not_found/)
    end
  end

  def process_entry(metadata)
    if metadata.is_a? DropboxApi::Metadata::File
      process_file metadata
    elsif metadata.is_a? DropboxApi::Metadata::Folder
      folders.each do |folder|
        if folder.path == metadata.path_display
          folder.created unless folder.to_be_destroyed?
        end
      end
    elsif metadata.is_a?(DropboxApi::Metadata::Deleted) && File.extname(metadata.name).empty?
      folders.each do |folder|
        next unless folder.path == metadata.path_display

        if folder.exist?
          folder.to_be_created
        elsif folder.to_be_destroyed?
          @folders -= [folder]
        end
      end
    end
  end

  def get_info_from_path(path)
    data = path.split('/')
    collaborator_code = nil

    if user.collaborator?
      collaborator_code = data[2]
      customer_info, period_type, journal_name = data[3..5]
    else
      customer_info, period_type, journal_name = data[2..4]
    end

    code = customer_info.split(' - ')[0].upcase
    customer = customers.select { |c| code == c.code }.first
    period_offset = period_type == 'période actuelle' ? 0 : 1

    [customer, journal_name.upcase, period_offset, collaborator_code]
  end

  def process_file(metadata)
    file_path = metadata.path_display
    path = File.dirname file_path
    file_name = File.basename file_path

    if valid_file_name(file_name)
      if needed_folders.include?(path)
        if UploadedDocument.valid_extensions.include?(File.extname(file_path).downcase)
          customer, journal_name, period_offset, collaborator_code = get_info_from_path path

          if customer.code == "AZC%DE"
            p "=================================== #{customer.code} ========================"
            begin
              CustomUtils.mktmpdir('dropbox_import') do |dir|
                File.open File.join(dir, file_name), 'wb' do |file|
                  client.download file_path do |content|
                    file.puts content.force_encoding('UTF-8')
                    file.flush
                  end

                  uploader = collaborator_code.present? ? user.memberships.find_by_code(collaborator_code) : user

                  corrupted_document_state = PdfIntegrator.verify_corruption(file.path)

                  p "=================================== #{file.path.to_s} ========================"
                  p "=================================== Fingerprint : #{DocumentTools.checksum(file.path)} ========================"

                  uploaded_document = UploadedDocument.new(file, file_name, customer, journal_name, period_offset, uploader, 'dropbox') if corrupted_document_state.to_s == 'continu'
                  if corrupted_document_state.to_s == 'uploaded' || uploaded_document.try(:valid?)
                    p "=================================== UPLOADED #{file_path}========================"

                    System::Log.info('processing', "[Dropbox Import][#{uploader.code}][SUCCESS]#{file_detail(uploaded_document)} #{file_path}")
                    client.delete file_path
                  else
                    p "=================================== ERROR #{file_name} ========================"

                    System::Log.info('processing', "[Dropbox Import][#{uploader.code}][#{uploaded_document.try(:errors).try(:last).try(:[], 0).to_s}] #{file_path}")
                    error = (corrupted_document_state.to_s == 'rejected') ? [[:real_corrupted_document]] : uploaded_document.errors
                    mark_file_error(path, file_name, error)
                  end
                end
              end
            rescue DropboxApi::Errors::NotFoundError
            end
          end
        else
          mark_file_error(path, file_name)
        end
      end
    end
  end

  def mark_file_error(path, file_name, errors=[])
    error_message = ERROR_LISTS[:unprocessable]
    errors.each do |err|
      error_message = ERROR_LISTS[err[0].to_sym] if ERROR_LISTS[err[0].to_sym].present?
    end

    basename = File.basename(file_name, '.*').gsub(/\(#{ERROR_LISTS[:file_is_corrupted_or_protected]}\)/, '').strip

    return false if basename =~ /#{error_message}/i

    new_file_name = basename + " (#{error_message})" + File.extname(file_name)
    client.move(File.join(path, file_name), File.join(path, new_file_name), autorename: true)
    rescue DropboxApi::Errors::NotFoundError
  end

  def update_folders
    remove_folders
    add_folders
  end

  def remove_folders
    paths = []
    folders.each do |folder|
      if folder.to_be_destroyed?
        if user.collaborator?
          customer = get_info_from_path(folder.path).first
          if customer && folder.path.match(/\/#{customer.code} - #{customer.company.gsub(/[\\\/\:\?\*\"\|&]/, '').strip}\//)
            paths << [folder.path, false]
          else
            paths << [folder.path.split('/')[0..3].join('/'), true]
          end
        else
          paths << [folder.path, false]
        end
      end
    end
    paths.uniq.each do |path, is_parent_folder|
      begin
        client.delete path
      rescue DropboxApi::Errors::FolderConflictError, DropboxApi::Errors::NotFoundError
      end
      @folders.delete_if do |folder|
        if is_parent_folder
          folder.path =~ /\A#{path}/
        else
          folder.path == path
        end
      end
    end
  end

  def add_folders
    @folders.each do |folder|
      if folder.to_be_created?
        begin
          client.create_folder folder.path
        rescue DropboxApi::Errors::FolderConflictError
        end
        folder.created
      end
    end
  end

  def file_detail(uploaded_document)
    file_size = ActionController::Base.helpers.number_to_human_size uploaded_document.temp_document.cloud_content_object.size
    "[TDID:#{uploaded_document.temp_document.id}][#{file_size}]"
  end

  def valid_file_name(file_name)
    ERROR_LISTS.each do |pattern|
      return false if file_name =~ /#{pattern.last}/i
    end
    return true
  end

  def check_for_all
    @dropbox.import_folder_paths.each do |path|
      next if not path.match(/AZC%DE/i)

      begin
        with_error = false
        result = client.list_folder(path)
      rescue => e
        with_error = true
      end

      next if with_error

      result.entries.each do |entry|
        process_entry entry
      end
    end

    # @dropbox.update(checked_at_for_all: Time.now)
  end
end