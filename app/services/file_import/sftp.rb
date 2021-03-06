class FileImport::Sftp
  ERROR_LISTS = {
                  already_exist: 'fichier déjà importé sur iDocus',
                  invalid_period: 'période invalide',
                  journal_unknown: 'journal invalide',
                  invalid_file_extension: 'extension invalide',
                  file_size_is_too_big: 'fichier trop volumineux, 10Mo max.',
                  pages_number_is_too_high: 'nombre de page trop important',
                  file_is_corrupted_or_protected: 'Votre document est en-cours de traitement',
                  real_corrupted_document: 'fichier corrompu ou protégé par mdp',
                  unprocessable: 'erreur fichier non valide pour iDocus'
                }.freeze

  class << self
    def process(sftp_id)
      UniqueJobs.for "ImportFtp-#{sftp_id}" do
        sftp = Sftp.find sftp_id
        FileImport::Sftp.new(sftp).execute
      end
    end
  end

  def initialize(sftp)
    @sftp = sftp
    @sftp.previous_import_paths ||= []
  end

  def execute
    return false if not @sftp.configured?
    return false if not @sftp.organization
    return false if customers.empty?

    System::Log.info('processing', "#{log_prefix} START")
    start_time = Time.now

    @sftp.clean_error

    return unless test_connection

    process

    sync_folder folder_tree

    System::Log.info('processing', "#{log_prefix} END (#{(Time.now - start_time).round(3)}s)")

    @sftp.update import_checked_at: Time.now, previous_import_paths: import_folders.map(&:path)
  end

  private

  def client
    return @client if @client

    @client = Sftp::Client.new(@sftp)

    @client
  end

  def test_connection
    client.dir.entries(@sftp.root_path || '/').map { |e| e.name }
    true
  rescue Errno::ETIMEDOUT => e
    log_infos = {
      subject: "[FileImport::Sftp] Errno::ETIMEDOUT test connection #{e.message}",
      name: "SFTPImport",
      error_group: "[sftp-import] Errno::ETIMEDOUT test connection",
      erreur_type: "SFTPImport - Errno::ETIMEDOUT test connection",
      date_erreur: Time.now.strftime('%Y-%m-%d %H:%M:%S'),
      more_information: {
        error_message: e.message,
        backtrace_error: e.backtrace.inspect,
        method: "test_connection"
      }
    }

    ErrorScriptMailer.error_notification(log_infos).deliver

    false
  rescue => e
    if e.message.match(/Login incorrect/)
      Notifications::Ftp.new({
        sftp: @sftp,
        users: @sftp.organization&.admins.presence || [@sftp.user],
        notice_type: @ftp.organization ? 'org_sftp_auth_failure' : 'sftp_auth_failure'
      }).notify_sftp_auth_failure

      @sftp.update is_configured: false
    end
    log_infos = {
      subject: "[FileImport::Sftp] ECONNREFUSED / SFTPPermError test connection #{e.message}",
      name: "SFTPImport",
      error_group: "[sftp-import] ECONNREFUSED / SFTPPermError test connection",
      erreur_type: "SFTPImport - SFTPTempError / SFTPPermError test connection",
      date_erreur: Time.now.strftime('%Y-%m-%d %H:%M:%S'),
      more_information: {
        error_message: e.message,
        backtrace_error: e.backtrace.inspect,
        method: "test_connection"
      }
    }

    ErrorScriptMailer.error_notification(log_infos).deliver

    false
  end

  def customers
    @customers ||= @sftp.organization.customers.active.order(code: :asc).
      select { |c| c.authorized_upload? }
  end

  # Pattern : /INPUT/code - journal (company)
  def folder_tree
    return @folder_tree if @folder_tree

    @folder_tree = last_item = FileImport::Sftp::Item.new ''

    if root_path != ''
      root_path.split('/').map(&:presence).compact.each do |folder|
        item = FileImport::Sftp::Item.new folder, true, true
        last_item.add item
        last_item = item
      end
    end

    input_item = FileImport::Sftp::Item.new 'INPUT', true, false
    last_item.add input_item

    current_folder_paths = []
    customers.each do |customer|
      company = customer.company.gsub(/[\\\/\:\?\*\"\|&]/, '').strip
      journal_names = customer.account_book_types.order(name: :asc).map(&:name)

      journal_names.each do |journal_name|
        name = "#{customer.code} - #{journal_name} (#{company})"
        item = FileImport::Sftp::Item.new(name, true, false)
        item.customer = customer
        item.journal = journal_name
        input_item.add item
        item.created if @sftp.previous_import_paths.include?(item.path)
        current_folder_paths << item.path
      end
    end

    if same_import_root_path?
      unused_folder_paths = @sftp.previous_import_paths - current_folder_paths
      unused_folder_paths.each do |unused_folder_path|
        name = unused_folder_path.split('/')[2]
        input_item.add FileImport::Sftp::Item.new(name, true, nil)
      end
    end

    @folder_tree = last_item

    validate_item @folder_tree

    @folder_tree
  end

  # Clean up root path
  # ''
  # '/' => ''
  # 'abc' => '/abc'
  # '/abc' => '/abc'
  # '/abc/' => '/abc'
  # 'abc/123' => '/abc/123'
  # '/abc/123' => '/abc/123'
  # '/abc/123/' => '/abc/123'
  def root_path
    return @root_path if @root_path

    @root_path = @sftp.root_path
    unless @root_path == ''
      if @root_path == '/'
        @root_path = ''
      else
        @root_path = '/' + @root_path unless @root_path.match(/\A\//)
        @root_path = @root_path.sub(/\/\z/, '') if @root_path.match(/\/\z/)
      end
    end
    @root_path
  end

  def same_import_root_path?
    return false if @sftp.previous_import_paths.empty?
    previous_import_root_path = @sftp.previous_import_paths.first.split('/')[0..-3].join('/')
    current_import_root_path = @sftp.root_path.split('/').join('/')
    current_import_root_path == previous_import_root_path
  end

  def validate_item(item)
    if item.children.present?
      path_names = begin
        client.dir.entries(item.path).map { |e| e.name }
      rescue => e
        if e.message.match(/(No such file or directory)|(Directory not found)|no such file/i)
          []
        else
          log_infos = {
            subject: "[FileImport::Sftp] SFTPTempError / SFTPPermError validate item #{e.message}",
            name: "SFTPImport",
            error_group: "[sftp-import] SFTPTempError / SFTPPermError validate item",
            erreur_type: "SFTPImport - SFTPTempError / SFTPPermError validate item",
            date_erreur: Time.now.strftime('%Y-%m-%d %H:%M:%S'),
            more_information: {
              item: item.path,
              error_message: e.message,
              backtrace_error: e.backtrace.inspect,
              method: "validate_item"
            }
          }

          ErrorScriptMailer.error_notification(log_infos).deliver

          raise
        end
      end
      item.children.each do |child|
        result = path_names.detect do |path|
          child.path.match(/#{Regexp.quote(path.force_encoding('UTF-8'))}\z/)
        end
        if result
          child.created if child.to_be_created?
          validate_item child
        else
          if child.to_be_destroyed?
            child.orphan
          elsif child.exist?
            child.to_be_created
            validate_item child
          end
        end
      end
    end
  end

  def sync_folder(item)
    if item.to_be_created?
      begin
        client.mkdir! item.path
      rescue => e
        if !e.message.match(/(No such file or directory)|(Directory not found)|no such file|failure/i)
          log_infos = {
            subject: "[FileImport::Sftp] synchronize folder #{e.message}",
            name: "SFTPImport",
            error_group: "[sftp-import] synchronize folder",
            erreur_type: "SFTPImport - synchronize folder",
            date_erreur: Time.now.strftime('%Y-%m-%d %H:%M:%S'),
            more_information: {
              item: item.path,
              error_type: e.class,
              error_message: e.message,
              backtrace_error: e.backtrace.inspect,
              method: "sync_folder"
            }
          }

          ErrorScriptMailer.error_notification(log_infos).deliver
        end

        false
      end
      item.created
    elsif item.to_be_destroyed?
      remove_item item
    end

    item.children.each do |child|
      sync_folder child
    end
  end

  def remove_item(item)
    item.children.each do |child|
      remove_item child
    end
    # TODO : remove artefact folders too
    files = begin
      client.dir.entries(item.path).map { |e| e.name }
    rescue => e
      if e.message.match(/(No such file or directory)|(Directory not found)|no such file|failure/i)
        []
      else
        log_infos = {
          subject: "[FileImport::Sftp] SFTPTempError / SFTPPermError remove item #{e.message}",
          name: "SFTPImport",
          error_group: "[sftp-import] SFTPTempError / SFTPPermError remove item",
          erreur_type: "SFTPImport - SFTPTempError / SFTPPermError remove item",
          date_erreur: Time.now.strftime('%Y-%m-%d %H:%M:%S'),
          more_information: {
            item: item.path,
            error_message: e.message,
            backtrace_error: e.backtrace.inspect,
            method: "remove_item"
          }
        }

        ErrorScriptMailer.error_notification(log_infos).deliver

        raise
      end
    end
    files.each do |file|
      next if not file.to_s.match(/.+[.].+/)
      client.remove! file
    end
    client.rmdir! item.path
    item.orphan
  end

  def import_folders
    @import_folders ||= last_items folder_tree
  end

  def last_items(item)
    if item.children.present?
      results = []
      item.children.each do |child|
        results += last_items(child)
      end
      results
    else
      [item]
    end
  end

  def process
    import_folders.each do |item|
      next if item.to_be_created? || item.customer.is_package?('ido_x')

      file_paths = begin
        client.dir.entries(item.path).map { |e| e.name }
      rescue => e
        if e.message.match(/No files found|no such file/i)
          []
        else
          log_infos = {
            subject: "[FileImport::Sftp] SFTPTempError / SFTPPermError process #{e.message}",
            name: "SFTPImport",
            error_group: "[sftp-import] SFTPTempError / SFTPPermError process",
            erreur_type: "SFTPImport - SFTPTempError / SFTPPermError process",
            date_erreur: Time.now.strftime('%Y-%m-%d %H:%M:%S'),
            more_information: {
              item: item.path,
              error_message: e.message,
              backtrace_error: e.backtrace.inspect,
              method: "process"
            }
          }

          ErrorScriptMailer.error_notification(log_infos).deliver

          raise
        end
      end

      file_paths.each do |untrusted_file_path|
        next if not untrusted_file_path.to_s.match(/.+[.].+/)

        file_name = File.basename(untrusted_file_path).force_encoding('UTF-8')
        file_path = File.join(item.path, file_name)

        next if file_name =~ /^\./
        next if not valid_file_name(file_name)

        if not UploadedDocument.valid_extensions.include?(File.extname(file_name).downcase)
          mark_file_error item.path, file_name, [[:invalid_file_extension]]
          next
        end

        # Don't check file size
        # if client.size(file_path) > 10.megabytes
        #   mark_file_error item.path, file_name, [[:file_size_is_too_big]]
        #   next
        # end

        CustomUtils.mktmpdir('sftp_import') do |dir|
          File.open File.join(dir, file_name), 'wb' do |file|
            client.download! file_path, file

            corrupted_document_state = PdfIntegrator.verify_corruption(file.path)

            uploaded_document = UploadedDocument.new file, file_name, item.customer, item.journal, 0, @sftp.organization, 'sftp' if corrupted_document_state.to_s == 'continu'

            if corrupted_document_state.to_s == 'uploaded' || uploaded_document.try(:valid?)
              System::Log.info('processing', "#{log_prefix}[SUCCESS]#{file_detail(uploaded_document)} #{file_path}")
              client.remove! file_path
            else
              System::Log.info('processing', "#{log_prefix}[INVALID][#{uploaded_document.try(:errors).try(:last).try(:[], 0).to_s}] #{file_path}")
              error = (corrupted_document_state.to_s == 'rejected') ? [[:real_corrupted_document]] : uploaded_document.errors
              mark_file_error(item.path, file_name, error)
            end
          end
        end
      end
    end
  end

  def mark_file_error(path, file_name, errors=[])
    error_message = ERROR_LISTS[:unprocessable]
    errors.each do |err|
      error_message = ERROR_LISTS[err[0].to_sym] if ERROR_LISTS[err[0].to_sym].present?
    end

    file_rename = File.basename(file_name, '.*').gsub(/\(#{ERROR_LISTS[:file_is_corrupted_or_protected]}\)/, '').strip
    file_rename = file_rename + " (#{error_message})" + File.extname(file_name)
    new_file_name = file_rename
    loop_count = 1
    error = true

    while (error && loop_count <= 5)
      begin
        client.rename! File.join(path, file_name), File.join(path, new_file_name)
        error = false
      rescue
        new_file_name = "#{loop_count}_#{file_rename}"
        loop_count += 1
      end
    end
  end

  def log_prefix
    @log_prefix ||= "[SFTP Import][#{@sftp.organization.code}]"
  end

  def file_detail(uploaded_document)
    file_size = ActionController::Base.helpers.number_to_human_size uploaded_document.temp_document.cloud_content_object.size
    "[TDID:#{uploaded_document.temp_document.id}][#{file_size}]"
  end

  def valid_file_name(file_name)
    ERROR_LISTS.each do |pattern|
      next if pattern.last =~ /#{ERROR_LISTS[:file_is_corrupted_or_protected]}/i

      return false if file_name =~ /#{pattern.last}/i
    end
    return true
  end
end