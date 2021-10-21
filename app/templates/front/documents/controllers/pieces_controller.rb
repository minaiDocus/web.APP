# frozen_string_literal: true

class Documents::PiecesController < FrontController
  skip_before_action :login_user!, only: %w[download get_piece_file get_temp_document_file handle_bad_url temp_document get_tag already_exist_document], raise: false
  skip_before_action :verify_if_active, only: %w[index show]
  before_action :load_pack, only: %w[show]

  prepend_view_path('app/templates/front/documents/views')

  # GET /documents
  def index
    _options = options

    @packs = Pack.includes(pieces: [:expense], owner: [:organization, :ibiza, :exact_online, :my_unisoft]).search(_options[:text], _options.reject{ |k,v| k == :ids}).distinct.order(updated_at: :desc).page(_options[:page]).per(_options[:per_page])
    @packs_with_failed_delivery_ids = packs_with_failed_delivery

    @period_service = Billing::Period.new user: @user

    @render_upload = request.xhr? ? false : true
  end

  # GET /documents/:id
  def show
    _options = options

    _options[:page] = params[:page] #IMPORTANT: per_page option must be a multiple of 4 and > 8 (needed by grid type view)
    _options[:per_page] =  8       #IMPORTANT: per_page option must be a multiple of 4 and > 8 (needed by grid type view)

    _options[:ids] = options[:piece_ids] if options[:piece_ids].present?

    # TODO : optimize created_at search
    #_options[:piece_created_at] = params[:by_piece].try(:[], :created_at)
    #_options[:piece_created_at_operation] = params[:by_piece].try(:[], :created_at_operation)

    pack = Pack.find(params[:id])

    @pieces_deleted = Pack::Piece.unscoped.where(pack_id: params[:id]).deleted.presence || []

    @pieces = @pack.pieces.search(_options[:text], _options).distinct.order(created_at: :desc).page(_options[:page]).per(_options[:per_page])

    @temp_pack      = TempPack.find_by_name(pack.name)
    @temp_documents = @temp_pack.temp_documents.not_published
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

  private

  def packs_with_failed_delivery
    reports = Pack::Report.where(pack_id: @packs.map(&:id))
    preseizures = Pack::Report::Preseizure.failed_delivery.where(report_id: reports.pluck(:id))
    reports_with_failed_delivery = Pack::Report.where(id: preseizures.pluck(:report_id))

    Pack.where(id: reports_with_failed_delivery.pluck(:pack_id)).pluck(:id)
  end

  def options
    if params[:by_all].present?
      params[:by_piece] = params[:by_piece].present? ? params[:by_piece].merge(params[:by_all].permit!) : params[:by_all]
    end

    options = { page: params[:page], per_page: 40 } #IMPORTANT: per_page option must be a multiple of 4 and > 8 (needed by grid type view)
    options[:sort] = true

    options[:text] = (params[:activate_filter].present? || params[:text].present?)? params[:text] : session[:params_document_piece].try(:[], :text)
    options[:text] = '' if params[:reinit].present?

    options[:piece_created_at] = params[:by_piece].try(:[], :created_at)
    options[:piece_created_at_operation] = params[:by_piece].try(:[], :created_at_operation)

    options[:position] = params[:by_piece].try(:[], :position)
    options[:position_operation] = params[:by_piece].try(:[], :position_operation)

    options[:tags] = params[:by_piece].try(:[], :tags)

    options[:pre_assignment_state] = params[:by_piece].try(:[], :state_piece)
    options[:piece_number] = params[:by_piece].try(:[], :piece_number)

    options[:by_preseizure] = params[:by_preseizure]

    if !params[:by_all].present? && !params[:by_piece].present? && !params[:by_preseizure].present?      
      options = session[:params_document_piece] if session[:params_document_piece].present? && !params[:reinit].present?
      session.delete(:params_document_piece)    if params[:reinit].present?            
    end

    options[:owner_ids] = if params[:activate_filter].present? || (params[:view].present? && params[:view] != 'all')
                            params[:view].try(:split, ',') || account_ids
                          elsif session[:params_document_piece].try(:[], :owner_ids).present?
                            session[:params_document_piece][:owner_ids]               
                          else
                            account_ids
                          end

    options[:journal] =   if params[:activate_filter].present? || params[:journal].present?
                            params[:journal].try(:split, ',') || []
                          elsif session[:params_document_piece].try(:[], :journal).present?
                            session[:params_document_piece][:journal]
                          else
                            []
                          end

    options[:badge_filter] =  if params[:badge_filter].present?
                                params[:badge_filter] 
                              elsif session[:params_document_piece].try(:[], :badge_filter).present?
                                session[:params_document_piece][:badge_filter]
                              else
                                ""
                              end


    if options[:by_preseizure].present? && (options[:by_preseizure].try(:[], 'is_delivered') != "" || options[:by_preseizure].try(:[], 'third_party') != "" || options[:by_preseizure].try(:[], 'delivery_tried_at') != "" || options[:by_preseizure].try(:[], 'date') != "" || options[:by_preseizure].try(:[], 'amount') != '')
      piece_ids = Pack::Report::Preseizure.where(user_id: options[:owner_ids]).where('piece_id > 0').filter_by(options[:by_preseizure]).distinct.pluck(:piece_id).presence || [0]
    end

    options[:piece_ids] = piece_ids if piece_ids.present?

    _temp_options = options.dup
    _temp_options = _temp_options.reject{ |k,v| k == :piece_ids }
    _temp_options = _temp_options.reject{ |k,v| k == :page }
    _temp_options = _temp_options.reject{ |k,v| k == :per_page }
    _temp_options = _temp_options.reject{ |k,v| k == :owner_ids } if options[:owner_ids].size >= 15
    session[:params_document_piece] = _temp_options if not params[:reinit].present?
    options
  end

  def load_pack
    @pack = Pack.where(id: params[:id]).first
    @pack = nil if not account_ids.include? @pack.owner_id

    redirect_to documents_path if not @pack
  end
end