# frozen_string_literal: true

class PiecesErrors::DuplicatedPreAssignmentController < FrontController
  prepend_view_path('app/templates/front/pieces_errors/views')

  # GET /account/pre_assignment_blocked_duplicates
  def index
    @duplicates = Pack::Report::Preseizure
                  .unscoped
                  .blocked_duplicates
                  .where(user_id: account_ids)
                  .search(search_terms(params[:duplicate_contains]))
                  .order("#{sort_real_column} #{sort_direction}")
                  .page(params[:page])
                  .per(params[:per_page])

    render partial: 'index'
  end

  def update_duplicated_preseizures
    preseizures = Pack::Report::Preseizure.unscoped.blocked_duplicates.where(user_id: account_ids, id: params[:duplicate_ids])

    if !preseizures.empty?
      success = true
      if params.keys.include?('unblock') && !params.keys.include?('approve_block')
        count = PreAssignment::Unblock.new(preseizures.map(&:id), @user).execute

        message = '1 pré-affectation a été débloqué.' if count == 1
        message ||= "#{count} pré-affectations ont été débloqués."
      elsif params.keys.include?('approve_block') && !params.keys.include?('unblock')
        count = preseizures.update_all(marked_as_duplicate_at: Time.now, marked_as_duplicate_by_user_id: @user.id)

        if count == 1
          message = '1 pré-affectation a été marqué comme étant un doublon.'
        end
        message ||= "#{count} pré-affectations ont été marqués comme étant des doublons."
      end
    else
      success = false
      message = 'Vous devez sélectionner au moins une pré-affectation.'
    end

    render json: { success: success, message: message }, state: 200
  end

  private

  def sort_column
    if params[:sort].in? %w[created_at piece_name piece_number third_party amount date]
      params[:sort]
    else
      'created_at'
    end
  end
  helper_method :sort_column

  def sort_real_column
    column = sort_column
    return 'pack_pieces.name' if column == 'piece_name'
    return 'cached_amount' if column == 'amount'

    column
  end

  def sort_direction
    if params[:direction].in? %w[asc desc]
      params[:direction]
    else
      'desc'
    end
  end
  helper_method :sort_direction
end