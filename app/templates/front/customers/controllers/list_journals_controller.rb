class Customers::ListJournalsController < OrganizationController
  before_action :load_customer
  before_action :redirect_to_current_step

  append_view_path('app/templates/front/customers/views')

  # GET /account/organizations/:organization_id/customers/:customer_id/list_journals
  def index
    @journals = @customer.account_book_types.order(name: :asc)
  end
end