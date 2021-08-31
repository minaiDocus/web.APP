# frozen_string_literal: true

class PiecesErrors::MainController < FrontController
  prepend_view_path('app/templates/front/pieces_errors/views')

  def index; end

  def ignored_pieces
    @ignored_list = Pack::Piece.pre_assignment_ignored
                               .where(user_id: account_ids)
                               .search(nil, search_terms(params[:filter_contains]))
                               .order("#{sort_column} #{sort_direction}")
                               .page(params[:page])
                               .per(params[:per_page])
  end
end