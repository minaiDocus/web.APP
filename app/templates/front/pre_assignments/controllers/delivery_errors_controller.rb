# frozen_string_literal: true

class PreAssignments::DeliveryErrorsController < FrontController
	append_view_path('app/templates/front/pre_assignments/views')

  # GET /pre_assignment_delivery_errors
  def index
    @errors = Pack::Report.failed_delivery(account_ids, 20)
  end
end