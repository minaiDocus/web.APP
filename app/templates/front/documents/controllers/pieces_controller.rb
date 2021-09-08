# frozen_string_literal: true

class Documents::PiecesController < FrontController
  skip_before_action :login_user!, only: %w[download piece handle_bad_url temp_document get_tag already_exist_document], raise: false
  before_action :load_pack, only: %w[show]

  prepend_view_path('app/templates/front/documents/views')

  # GET /documents
  def index
    @packs = Pack.search(params.try(:[], :by_piece).try(:[], :content), options).distinct.order(updated_at: :desc).page(options[:page]).per(options[:per_page])

    @period_service = Billing::Period.new user: @user
  end

  # GET /documents/:id
  def show
    _options = options
    _options[:ids] = options[:piece_ids] if options[:piece_ids].present?

    # TODO : optimize created_at search
    #_options[:piece_created_at] = params[:by_piece].try(:[], :created_at)
    #_options[:piece_created_at_operation] = params[:by_piece].try(:[], :created_at_operation)

    @pieces_deleted = Pack::Piece.unscoped.where(pack_id: params[:id]).deleted.presence || []

    @pieces = @pack.pieces.search(params[:text], _options).distinct.order(created_at: :desc).page(_options[:page]).per(_options[:per_page])
  end

  def delete
    pieces_ids  = Array(params[:ids] || [])
    # pieces_ids  = [] #FOR test
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
            if parent_document.children.size == parent_document.children.fingerprint_is_nil.size
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

  private

  def options
    if params[:by_all].present?
      params[:by_piece] = params[:by_piece].present? ? params[:by_piece].merge(params[:by_all].permit!) : params[:by_all]
    end

    options = { page: params[:page], per_page: 16 } #IMPORTANT: per_page option must be a multiple of 4 and > 4 (needed by grid type view)
    options[:sort] = true

    options[:piece_created_at] = params[:by_piece].try(:[], :created_at)
    options[:piece_created_at_operation] = params[:by_piece].try(:[], :created_at_operation)

    options[:piece_position] = params[:by_piece].try(:[], :position)
    options[:piece_position_operation] = params[:by_piece].try(:[], :position_operation)

    options[:name] = params[:text]
    options[:tags] = params[:by_piece].try(:[], :tags)

    options[:pre_assignment_state] = params[:by_piece].try(:[], :state_piece)

    options[:owner_ids] = if params[:view].present? && params[:view] != 'all'
                            _user = accounts.find(params[:view])
                            _user ? [_user.id] : []
                          else
                            account_ids
                          end

    if params[:by_preseizure].present? && (params[:by_preseizure].try(:[], 'is_delivered').present? || params[:by_preseizure].try(:[], 'delivery_tried_at').present? || params[:by_preseizure].try(:[], 'date').present? || params[:by_preseizure].try(:[], 'amount').present?)
      piece_ids = Pack::Report::Preseizure.where(user_id: options[:owner_ids], operation_id: ['', nil]).filter_by(params[:by_preseizure]).distinct.pluck(:piece_id).presence || [0]
    end

    options[:piece_ids] = piece_ids if piece_ids.present?

    options
  end

  def load_pack
    @pack = Pack.where(id: params[:id]).first
    @pack = nil if not account_ids.include? @pack.owner_id

    redirect_to documents_path if not @pack
  end
end