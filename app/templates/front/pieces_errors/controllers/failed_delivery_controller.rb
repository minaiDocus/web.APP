# frozen_string_literal: true

class PiecesErrors::FailedDeliveryController < FrontController
  append_view_path('app/templates/front/pieces_errors/views')

  # GET /account/pre_assignment_blocked_duplicates
  def index
    @errors = Pack::Report.failed_delivery(account_ids, 20)

    render partial: 'index'
  end
end