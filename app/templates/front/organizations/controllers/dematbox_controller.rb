# frozen_string_literal: true

class Organizations::DematboxController < OrganizationController
  before_action :load_customer
  before_action :verify_access
  before_action :load_dematbox

  prepend_view_path('app/templates/front/organizations/views')

  # POST /account/organizations/:organization_id/customers/:customer_id/dematbox
  def create
    @dematbox.subscribe(params[:pairing_code])

    flash[:success] = "Configuration de iDocus'Box en cours..."

    redirect_to organization_customer_path(@organization, @customer, tab: 'idocus_box')
  end

  # DELETE /account/organizations/:organization_id/customers/:customer_id/dematbox
  def destroy
    @dematbox.unsubscribe

    flash[:success] = 'Supprimé avec succèss.'

    redirect_to organization_customer_path(@organization, @customer, tab: 'idocus_box')
  end

  private

  def verify_access
    unless @customer.my_package.try(:scan_active)
      flash[:success] = t('authorization.unessessary_rights')

      redirect_to organization_customer_path(@organization, @customer)
    end
  end

  def load_dematbox
    @dematbox = @customer.dematbox || Dematbox.create(user_id: @customer.id)
  end
end
