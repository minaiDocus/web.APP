# frozen_string_literal: true
class UseCsvDescriptors::MainController < FrontController
  before_action :verify_rights
  before_action :load_customer
  before_action :redirect_to_current_step

  append_view_path('app/templates/front/use_csv_descriptors/views')

  # FIXME : check if needed
  def edit; end

  def update
    if @customer.update(user_params)
      next_configuration_step
    else
      render :edit
    end
  end

  private

  def verify_rights
    unless @user.is_admin || (@user.is_prescriber && @user.organization == @organization) || @organization.try(:csv_descriptor).try(:used?)
      flash[:error] = t('authorization.unessessary_rights')
      redirect_to account_organization_path(@organization)
    end
  end

  def user_params
    params.require(:user).permit(csv_descriptor_attributes: %i[id use_own_csv_descriptor_format])
  end
end