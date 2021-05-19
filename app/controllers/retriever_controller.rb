# frozen_string_literal: true

class RetrieverController < OrganizationController
  before_action :load_customer
  before_action :redirect_to_current_step
  before_action :verify_rights

  append_view_path('app/templates/front/organization/views')

  private

  def load_customer
    @customer = customers.find(params[:customer_id])
  end

  def verify_rights
    unless ((@user.leader? || @user.manage_customers) && @customer.active? && @customer.options.is_retriever_authorized && @customer.organization.is_active) || @customer.organization.specific_mission
      flash[:error] = t('authorization.unessessary_rights')

      redirect_to organizations_organizations_path(@organization)
    end
  end
end
