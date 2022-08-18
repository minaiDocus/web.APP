# frozen_string_literal: true

class DocumentsReloaded::PiecesController < Documents::AbaseController
  skip_before_action :login_user!, only: %w[download get_piece_file get_temp_document_file handle_bad_url temp_document get_tag already_exist_document], raise: false
  skip_before_action :verify_if_active, only: %w[index show]
  before_action :set_is_document
  before_action :load_params, only: %w[index show]

  prepend_view_path('app/templates/front/documents_reloaded/views')

  # GET /documents_reloaded
  def index
    if @user.collaborator?
      @collaborator_view  = true
      index_collaborators      
    else
      @collaborator_view = false
      index_customers
    end
  end

  # GET /documents_reloaded/:id
  def show
    @piece = Pack::Piece.find params[:id]

    render partial: 'detail'
  end

  def delete
    pieces_ids  = Array(params[:ids] || [])
    pack        = nil

    pieces_ids.each do |piece_id|
      piece           = Pack::Piece.find piece_id
      piece.delete_at = DateTime.now
      piece.delete_by = @user.code
      piece.save

      temp_document = piece.temp_document

      if temp_document
        temp_document.original_fingerprint    = nil
        temp_document.content_fingerprint     = nil
        temp_document.raw_content_fingerprint = nil
        temp_document.save

        parents_documents = temp_document.parents_documents

        if parents_documents.any?
          parents_documents.each do |parent_document|
            blank_children =  parent_document.children.select{ |child| child.fingerprint_is_nil? }

            if parent_document.children.size == blank_children.size
              parent_document.original_fingerprint    = nil
              parent_document.content_fingerprint     = nil
              parent_document.raw_content_fingerprint = nil
              parent_document.save
            end
          end
        end
      end

      pack ||= piece.pack
    end

    pack.delay.try(:recreate_original_document) if pack

    render json: { success: true, json_flash: { success: 'Pièce(s) supprimée(s) avec succès' } }, status: 200
  end

  def restore
    piece = Pack::Piece.unscoped.find params[:id]

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

    render json: { success: true, json_flash: { success: 'Pièce réstorée avec succès' } }, status: 200
  end

  # GET /account/documents/:id/download/:style
  def get_piece_file
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

  # GET /account/documents/temp_documents/:id/download/:style
  def get_temp_document_file
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

  def update_analytics
    pieces = Pack::Piece.where(id: params[:pieces_ids].presence || 0).where("pre_assignment_state != 'ready'")

    messages = PiecesAnalyticReferences.new(pieces, params[:analysis][:analytic]).update_analytics

    render json: { json_flash: { error: messages[:error_message], success: messages[:sending_message] } }, status: 200
  end

  def index_collaborators
    @options[:page]     = params[:page]
    @options[:per_page] = params[:per_page]

    @options[:ids] = @options[:piece_ids] if @options[:piece_ids].present?

    # TODO : optimize created_at search
    #@options[:piece_created_at] = @options[:by_piece].try(:[], :created_at)
    #@options[:piece_created_at_operation] = @options[:by_piece].try(:[], :created_at_operation)

    ids = accounts.collect(&:id)
    @pieces_deleted = Pack::Piece.unscoped.where(user_id: ids).deleted.presence || []

    @pieces = Pack::Piece.where(user_id: ids).search(@options[:text], @options).distinct.order(created_at: :desc).page(@options[:page]).per(@options[:per_page])

    # @temp_pack      = TempPack.find_by_name(pack.name)
     @temp_pack      = TempPack.find_by_name(@pieces.first.pack.name)
     @temp_documents = @temp_pack.temp_documents.not_published
  end

  def index_customers
    @render_upload = request.xhr? ? false : true

    @options[:page]     = params[:page]
    @options[:per_page] =  20

    user_ids = accounts.includes(:options, :ibiza, :subscription, organization: [:ibiza, :exact_online, :my_unisoft, :coala, :cogilog, :sage_gec, :acd, :quadratus, :cegid, :csv_descriptor, :fec_agiris]).active.order(code: :asc).select { |user| user.authorized_upload? }.collect(&:id)

    @temp_documents = TempDocument.where(user_id: user_ids).page(@options[:page]).per(@options[:per_page])
  end

  private

  def packs_with_failed_delivery
    reports = Pack::Report.where(pack_id: @packs.map(&:id))
    # preseizures = Pack::Report::Preseizure.failed_delivery.where(report_id: reports.pluck(:id))
    preseizures = Pack::Report::Preseizure.not_delivered('ibiza').where(report_id: reports.pluck(:id)) #JUST IBIZA FOR NOW
    reports_with_failed_delivery = Pack::Report.where(id: preseizures.not_deleted.pluck(:report_id))

    Pack.where(id: reports_with_failed_delivery.pluck(:pack_id)).pluck(:id)
  end

  def set_is_document
    @is_documents = true
  end
end