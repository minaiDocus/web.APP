# frozen_string_literal: true
class PreAssignmentDeliveryErrors::MainController < FrontController
  append_view_path('app/templates/front/pre_assignment_delivery_errors/views')

  # GET /account/pre_assignment_delivery_errors
  def index
    @errors = Pack::Report.failed_delivery(account_ids, 20)
  end
end