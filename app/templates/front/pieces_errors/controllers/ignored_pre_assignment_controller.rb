# frozen_string_literal: true

class PiecesErrors::IgnoredPreAssignmentController < FrontController
  prepend_view_path('app/templates/front/pieces_errors/views')

  def index
    @ignored_list = Pack::Piece.pre_assignment_ignored
                               .where(user_id: account_ids)
                               .search(nil, search_terms(params[:filter_contains]))
                               .order("#{sort_column} #{sort_direction}")
                               .page(params[:page])
                               .per(params[:per_page])

    render partial: 'index'
  end

  def update_ignored_pieces
    if params[:confirm_ignorance].present?
      message = confirm_ignored_pieces
    elsif params[:force_pre_assignment].present?
      message = force_pre_assignment
    end

    render json: { success: true, message: message }, state: 200
  end

  private

  def force_pre_assignment
    pieces = Pack::Piece.pre_assignment_ignored.where(user_id: account_ids, id: params[:ignored_ids])

    if !pieces.empty?
      pieces.each(&:force_processing_pre_assignment)

      message = 'Renvoi en pré-affectation en cours ...'
    else
      message = 'Vous devez sélectionner au moins une pièce.'
    end
  end

  def confirm_ignored_pieces
    pieces = Pack::Piece.where(pre_assignment_state: 'ignored', user_id: account_ids, id: params[:ignored_ids])

    if !pieces.empty?
      pieces.each(&:confirm_ignorance_pre_assignment)

      message = 'Modifié avec succès.'
    else
      message = 'Impossible de traiter la demande.'
    end
  end

  def sort_column
    if params[:sort].in? %w[created_at name number pre_assignment_state]
      params[:sort]
    else
      'created_at'
    end
  end
  helper_method :sort_column

  def sort_direction
    if params[:direction].in? %w[asc desc]
      params[:direction]
    else
      'desc'
    end
  end
  helper_method :sort_direction
end