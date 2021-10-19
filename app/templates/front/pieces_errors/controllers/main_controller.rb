# frozen_string_literal: true

class PiecesErrors::MainController < FrontController
  skip_before_action :verify_if_active, only: %w[index]
  prepend_view_path('app/templates/front/pieces_errors/views')

  def index; end
end