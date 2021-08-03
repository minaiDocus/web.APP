# frozen_string_literal: true

class Documents::MainController < FrontController
  skip_before_action :login_user!, only: %w[download piece handle_bad_url temp_document get_tag already_exist_document], raise: false

  append_view_path('app/templates/front/documents/views')

  def export_options
    if params[:type] == 'piece'
      obj = Pack::Piece.where(id: Array(params[:ids])).first
    elsif params[:type] == 'preseizure'
      obj = Pack::Report::Preseizure.where(id: Array(params[:ids])).first
    elsif params[:pack] == 'pack'
      obj = Pack.where(id: Array(params[:ids])).first
    elsif params[:report] == 'report'
      obj = Pack::Report.where(id: Array(params[:ids])).first
    end

    user    = obj.try(:user) || obj.try(:owner)
    options = []

    if user
      options << %w[CSV csv] if user.uses?(:csv_descriptor)
      if current_user.is_admin && user.organization.ibiza.try(:configured?) && user.uses?(:ibiza)
        options << ['XML (Ibiza)', 'xml_ibiza']
      end
      options << ['TXT (Quadratus)', 'txt_quadratus']          if user.uses?(:quadratus)
      options << ['ZIP (Quadratus)', 'zip_quadratus']          if user.uses?(:quadratus)
      options << ['ZIP (Coala)', 'zip_coala']                  if user.uses?(:coala)
      options << ['XLS (Coala)', 'xls_coala']                  if user.uses?(:coala)
      options << ['CSV (Cegid)', 'csv_cegid']                  if user.uses?(:cegid)
      options << ['TRA + pièces jointes (Cegid)', 'tra_cegid'] if user.uses?(:cegid)
      options << ['TXT (Fec Agiris)', 'txt_fec_agiris']        if user.uses?(:fec_agiris)
      options << ['TXT (Fec ACD)', 'txt_fec_acd']              if user.uses?(:fec_acd)
    end

    options << ['Aucun logiciel comptable paramètré', ''] if options.empty?

    render json: { options: options }, status: 200
  end

  def export_preseizures
    params64 = Base64.decode64(params[:q])
    params64 = JSON.parse(params64)

    export_type = params64['type']
    export_ids  = Array(params64['ids'] || [])
    export_format = params64['format']

    preseizures = []

    if export_ids.any?
      if export_type == 'piece'
        pieces = Pack::Piece.where(id: export_ids)
        preseizures = pieces.collect(&:preseizures).flatten.compact if pieces.any?
      elsif export_type == 'preseizure'
        preseizures = Pack::Report::Preseizure.where(id: export_ids)
        if preseizures.any?
          @report = preseizures.first.report
          update_report
          preseizures.reload
        end
      elsif export_type == 'pack'
        pack = Pack.where(id: export_ids).first
        reports = pack.present? ? assign_report_with(pack) : []
        preseizures = Pack::Report::Preseizure.not_deleted.where(report_id: reports.collect(&:id))
      elsif export_type == 'report'
        @report = Pack::Report.where(id: export_ids).first
        update_report
        preseizures = Pack::Report.where(id: export_ids).first.preseizures
      end
    end

    supported_format = %w[csv xml_ibiza txt_quadratus zip_quadratus zip_coala xls_coala txt_fec_agiris txt_fec_acd csv_cegid tra_cegid]

    if preseizures.any? && export_format.in?(supported_format)
      preseizures = preseizures.by_position

      export = PreseizureExport::GeneratePreAssignment.new(preseizures, export_format).generate_on_demand
      if export && export.file_name.present? && export.file_path.present?
        contents = File.read(export.file_path.to_s)

        send_data(contents, filename: File.basename(export.file_name.to_s), disposition: 'attachment')
      else
        render plain: 'Aucun résultat'
      end
    elsif !export_format.in?(supported_format)
      render plain: 'Traitement impossible : le format est incorrect.'
    else
      render plain: 'Aucun résultat'
    end
  end

  def download_archive
    pack = Pack.find(params[:id])
    pack = nil unless pack.owner.in?(accounts)

    begin
      if !pack.cloud_archive.attached? || pack.archive_name.gsub('%', '_') != pack.try(:cloud_archive_object).try(:filename)
        pack.save_archive_to_storage #May takes several times
      end

      zip_path = pack.cloud_archive_object.reload.path.presence || pack.archive_file_path

      ok = pack && File.exist?(zip_path)
    rescue => e
      ok = false
    end

    if ok
      send_file(zip_path, type: 'application/zip', filename: pack.archive_name, x_sendfile: true)
    else
      render plain: "File unavalaible"
    end
  end

  def download_bundle
    @pack = Pack.find params[:id]
    filepath = @pack.cloud_content_object.path

    if File.exist?(filepath.to_s) && (@pack.owner.in?(accounts) || current_user.try(:is_admin))
      mime_type = 'application/pdf'
      send_file(filepath, type: mime_type, filename: @pack.cloud_content_object.filename, x_sendfile: true, disposition: 'inline')
    else
      render body: nil, status: 404
    end
  end

  def get_tags
    if params[:type] == 'pack'
      @models = Pack.where(id: params[:id])
    else
      @models = Pack::Piece.where(id: params[:id])
    end

    render partial: 'tags'
  end

  def update_tags
    UpdateMultipleTags.execute(@user, params[:tags], Array(params[:ids]), params[:type])

    render json: {message: 'Tag mis à jours avec succès'}, status: :ok
  end

  def deliver_preseizures
    if @user.has_collaborator_action?
      export_type = params[:type]
      export_ids  = Array(params[:ids] || [])

      preseizures = []

      if export_ids.any?
        if export_type == 'piece'
          pieces = Pack::Piece.where(id: export_ids)
          preseizures = pieces.collect(&:preseizures).flatten.compact if pieces.any?
        elsif export_type == 'preseizure'
          preseizures = Pack::Report::Preseizure.where(id: export_ids)
        elsif export_type == 'pack'
          pack = Pack.where(id: export_ids).first
          reports = pack.present? ? assign_report_with(pack) : []
          preseizures = Pack::Report::Preseizure.not_deleted.where(report_id: reports.collect(&:id))
        elsif export_type == 'report'
          preseizures = Pack::Report.where(id: export_ids).first.preseizures
        end
      end

      if preseizures.any?
        preseizures.group_by(&:report_id).each do |_report_id, preseizures_by_report|
          PreAssignment::CreateDelivery.new(preseizures_by_report, %w[ibiza exact_online my_unisoft]).execute
        end
      end

      render json: { success: true }, status: 200
    else
      render json: { success: true }, status: 200
    end
  end


###################################################################################################

  # GET /account/documents/preseizure_account/:id
  def preseizure_account
    @preseizure = Pack::Report::Preseizure.find params[:id]

    user = @preseizure.try(:user)
    @ibiza = user.try(:organization).try(:ibiza)
    @software = @software_human_name = ''
    if user.try(:uses?, :ibiza)
      @software = 'ibiza'
      @software_human_name = 'Ibiza'
    elsif user.try(:uses?, :exact_online)
      @software = 'exact_online'
      @software_human_name = 'Exact Online'
    end

    @unit = @preseizure.try(:unit) || 'EUR'
    @preseizure_entries = @preseizure.entries

    @pre_tax_amount = @preseizure_entries.select { |entry| entry.account.type == 2 }.try(:first).try(:amount) || 0
    analytics = @preseizure.analytic_reference
    @data_analytics = []
    if analytics
      3.times do |i|
        j = i + 1
        references = analytics.send("a#{j}_references")
        name       = analytics.send("a#{j}_name")
        next unless references.present?

        references = JSON.parse(references)
        references.each do |ref|
          if name.present? && ref['ventilation'].present? && (ref['axis1'].present? || ref['axis2'].present? || ref['axis3'].present?)
            @data_analytics << { name: name, ventilation: ref['ventilation'], axis1: ref['axis1'], axis2: ref['axis2'], axis3: ref['axis3'] }
            end
        end
      end
    end

    render partial: 'documents/main/preseizures/preseizure_account'
  end


  def update_multiple_preseizures
    if @user.has_collaborator_action?
      preseizures = Pack::Report::Preseizure.where(id: params[:ids])

      real_params = update_multiple_preseizures_params
      begin
        error = ''
        preseizures.update_all(real_params) if real_params.present?
      rescue StandardError => e
        error = 'Impossible de modifier la séléction'
      end

      render json: { error: error }, status: 200
    else
      render json: { error: '' }, status: 200
    end
  end

  def multi_pack_download
    CustomUtils.add_chmod_access_into("/nfs/tmp/")
    _tmp_archive = Tempfile.new(['archive', '.zip'], '/nfs/tmp/')
    _tmp_archive_path = _tmp_archive.path
    _tmp_archive.close
    _tmp_archive.unlink

    params_valid = params[:pack_ids].present?
    ready_to_send = false

    if params_valid
      packs = Pack.where(id: params[:pack_ids].split('_')).order(created_at: :desc)

      files_path = packs.map do |pack|
        document = pack.original_document
        if document && (pack.owner.in?(accounts) || curent_user.try(:is_admin))
          document.cloud_content_object.path
        end
      end
      files_path.compact!

      files_path.in_groups_of(50).each do |group|
        DocumentTools.archive(_tmp_archive_path, group)
      end

      ready_to_send = true if files_path.any? && File.exist?(_tmp_archive_path)
    end

    if ready_to_send
      begin
        contents = File.read(_tmp_archive_path)
        File.unlink _tmp_archive_path if File.exist?(_tmp_archive_path)

        send_data(contents, type: 'application/zip', filename: 'pack_archive.zip', disposition: 'attachment')
      rescue StandardError
        File.unlink _tmp_archive_path if File.exist?(_tmp_archive_path)
        redirect_to account_path, alert: 'Impossible de proceder au téléchargment'
      end
    else
      File.unlink _tmp_archive_path if File.exist?(_tmp_archive_path)
      redirect_to account_path, alert: 'Impossible de proceder au téléchargment'
    end
  end

  # POST /account/documents/sync_with_external_file_storage
  def sync_with_external_file_storage
    if current_user.is_admin
      @packs = params[:pack_ids].present? ? Pack.where(id: params[:pack_ids]) : all_packs
      @packs = @packs.order(created_at: :desc)

      type = params[:type].to_i || FileDelivery::RemoteFile::ALL

      @packs.each do |pack|
        FileDelivery.prepare(pack, users: [@user], type: type, force: true, delay: true)
      end
    end

    respond_to do |format|
      format.html { render body: nil, status: 200 }
      format.json { render json: true, status: :ok }
    end
  end

  # GET /account/documents/processing/:id/download/:style
  def download_processing
    document = TempDocument.find(params[:id])
    owner    = document.temp_pack.user
    filepath = document.cloud_content_object.path(params[:style].presence)

    if File.exist?(filepath) && (owner.in?(accounts) || current_user.try(:is_admin))
      mime_type = File.extname(filepath) == '.png' ? 'image/png' : 'application/pdf'
      send_file(filepath, type: mime_type, filename: document.cloud_content_object.filename, x_sendfile: true, disposition: 'inline')
    else
      render body: nil, status: 404
    end
  end

  # GET /account/documents/:id/download/:style
  def download
    begin
      document = params[:id].size > 20 ? Document.find_by_mongo_id(params[:id]) : Document.find(params[:id])
      owner    = document.pack.owner
      filepath = document.cloud_content_object.path(params[:style].presence)
    rescue StandardError
      document = params[:id].size > 20 ? TempDocument.find_by_mongo_id(params[:id]) : TempDocument.find(params[:id])
      owner    = document.temp_pack.user
      filepath = document.cloud_content_object.path(params[:style].presence)
    end

    if File.exist?(filepath) && (owner.in?(accounts) || current_user.try(:is_admin) || params[:token] == document.get_token)
      mime_type = File.extname(filepath) == '.png' ? 'image/png' : 'application/pdf'
      send_file(filepath, type: mime_type, filename: document.cloud_content_object.filename, x_sendfile: true, disposition: 'inline')
    else
      render body: nil, status: 404
    end
  end

  # GET /account/documents/pieces/:id/download
  def piece
    # NOTE : support old MongoDB id for pieces uploaded to iBiZa, in CSV export or others
    auth_token = params[:token]
    auth_token ||= request.original_url.partition('token=').last

    @piece = params[:id].length > 20 ? Pack::Piece.find_by_mongo_id(params[:id]) : Pack::Piece.unscoped.find(params[:id])
    filepath = @piece.cloud_content_object.path(params[:style].presence || :original)

    if !File.exist?(filepath.to_s) && !@piece.cloud_content.attached?
      sleep 1
      @piece.try(:recreate_pdf)
      filepath = @piece.cloud_content_object.reload.path(params[:style].presence || :original)
    end

    if File.exist?(filepath.to_s) && (@piece.pack.owner.in?(accounts) || current_user.try(:is_admin) || auth_token == @piece.get_token)
      mime_type = File.extname(filepath) == '.png' ? 'image/png' : 'application/pdf'
      send_file(filepath, type: mime_type, filename: @piece.cloud_content_object.filename, x_sendfile: true, disposition: 'inline')
    else
      render body: nil, status: 404
    end
  end

  # GET /account/documents/pieces/download_selected/:pieces_ids
  def download_selected
    pieces_ids   = params[:pieces_ids].split('_')
    merged_paths = []
    pieces       = []

    pieces_ids.each do |piece_id|
      piece = Pack::Piece.unscoped.find(piece_id)
      file_path = piece.cloud_content_object.path(params[:style].presence || :original)

      if !File.exist?(file_path.to_s) && !piece.cloud_content.attached?
        sleep 1
        piece.try(:recreate_pdf)
        file_path = piece.cloud_content_object.reload.path(params[:style].presence || :original)
      end

      merged_paths << file_path
      pieces << piece
    end

    if pieces.last.user.in?(accounts) || current_user.try(:is_admin)
      tmp_dir      = CustomUtils.mktmpdir('download_selected', nil, false)
      file_path    = File.join(tmp_dir, "#{pieces_ids.size}_selected_pieces.pdf")

      if merged_paths.size > 1
        is_merged = Pdftk.new.merge merged_paths, file_path
      else
        is_merged = true
        FileUtils.cp merged_paths.first, file_path
      end

      if is_merged && File.exist?(file_path.to_s)
        mime_type = File.extname(file_path) == '.png' ? 'image/png' : 'application/pdf'
        send_file(file_path, type: mime_type, filename: File.basename(file_path), x_sendfile: true, disposition: 'inline')
      else
        render body: nil, status: 404
      end
    else
      render body: nil, status: 404
    end
  end

  # GET /account/documents/temp_documents/:id/download
  def temp_document
    auth_token = params[:token]
    auth_token ||= request.original_url.partition('token=').last

    @temp_document = TempDocument.find(params[:id])
    filepath = @temp_document.cloud_content_object.reload.path(params[:style].presence || :original)

    if File.exist?(filepath.to_s) && (@temp_document.user.in?(accounts) || current_user.try(:is_admin) || auth_token == @temp_document.get_token)
      mime_type = File.extname(filepath) == '.png' ? 'image/png' : 'application/pdf'
      send_file(filepath, type: mime_type, filename: @temp_document.cloud_content_object.filename, x_sendfile: true, disposition: 'inline')
    else
      render body: nil, status: 404
    end
  end

  # GET /account/documents/exist_document/:id/download
  def exist_document
    auth_token = params[:token]
    auth_token ||= request.original_url.partition('token=').last

    already_doc = Archive::AlreadyExist.find(params[:id])
    filepath    = already_doc.path

    if File.exist?(filepath.to_s) && auth_token == already_doc.get_token
      mime_type = File.extname(filepath) == '.png' ? 'image/png' : 'application/pdf'
      # send_file(filepath, type: mime_type, filename: "document_already_exist.pdf", x_sendfile: true, disposition: 'inline')
      send_data File.read(filepath), filename: "document_already_exist.pdf", type: mime_type, disposition: 'inline' ## TODO: Find why send file doesn't work here
    else
      render body: nil, status: 404
    end
  end

  # GET /contents/original/missing.png
  def handle_bad_url
    token = request.original_url.partition('token=').last

    @piece = Pack::Piece.where('created_at >= ?', '2019-12-28 00:00:00').where('created_at <= ?', '2019-12-31 23:59:59').find_by_token(token)
    filepath = @piece.cloud_content_object.path(:original)

    if File.exist?(filepath)
      mime_type = File.extname(filepath) == '.png' ? 'image/png' : 'application/pdf'

      send_file(filepath, type: mime_type, filename: @piece.cloud_content_object.filename, x_sendfile: true, disposition: 'inline')
    else
      render body: nil, status: 404
    end
  end

  # POST /account/documents/restore_piece
  def restore_piece
    piece = Pack::Piece.unscoped.find params[:piece_id]

    piece.delete_at = nil
    piece.delete_by = nil

    piece.save

    temp_document = piece.temp_document

    parents_documents = temp_document.parents_documents

    temp_document.original_fingerprint = DocumentTools.checksum(temp_document.cloud_content_object.path)
    temp_document.save

    if parents_documents.any?
      parents_documents.each do |parent_document|
        parent_document.original_fingerprint = DocumentTools.checksum(parent_document.cloud_content_object.path)
        parent_document.save
      end
    end

    pack = piece.pack

    pack.delay.try(:recreate_original_document)

    temp_pack = TempPack.find_by_name(pack.name)

    piece.waiting_pre_assignment if temp_pack.is_compta_processable? && piece.preseizures.size == 0 && piece.temp_document.try(:api_name) != 'invoice_auto' && !piece.pre_assignment_waiting_analytics?

    render json: { success: true }, status: 200
  end

  def already_exist_document
    @already_document = Archive::AlreadyExist.where(id: params[:id]).first
  end

  private

  def update_multiple_preseizures_params
    {
      date: params[:preseizures_attributes][:date].presence,
      deadline_date: params[:preseizures_attributes][:deadline_date].presence,
      third_party: params[:preseizures_attributes][:third_party].presence,
      currency: params[:preseizures_attributes][:currency].presence,
      conversion_rate: params[:preseizures_attributes][:conversion_rate].presence,
      observation: params[:preseizures_attributes][:observation].presence
    }.compact
  end

  #####################

  def assign_report_with(pack)
    reports = Pack::Report.where(name: pack.name.gsub('all', '').strip)
    if reports.any?
      reports.each do |report|
        report.update(pack_id: pack.id) if report.pack_id.nil? && report.preseizures.first.try(:piece_id).present?
      end

      reports.reload
    end

    reports
  end

  def update_report
    if @report && @report.name
      pack = Pack.where(name: @report.name + ' all').first
      assign_report_with(pack) if pack.present?
    end
  end
end