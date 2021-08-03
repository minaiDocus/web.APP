# frozen_string_literal: true

class Documents::PiecesController < FrontController
  skip_before_action :login_user!, only: %w[download piece handle_bad_url temp_document get_tag already_exist_document], raise: false
  before_action :load_pack, only: %w[show]

  append_view_path('app/templates/front/documents/views')

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

    @pieces = @pack.pieces.search(params[:text], _options).distinct.order(created_at: :desc).page(_options[:page]).per(_options[:per_page])
  end

  def delete
    pieces_ids  = Array(params[:ids] || [])
    pieces_ids  = [] #FOR test
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

    render json: { success: true }, status: 200
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