# frozen_string_literal: true

class MyCompanyFiles::CustomerController < OrganizationController

  before_action :load_customer
  before_action :verify_rights

  prepend_view_path('app/templates/front/my_company_files/views')

  def edit_mcf; end

  def show_mcf_errors
    order_by = params[:sort] || 'created_at'
    direction = params[:direction] || 'desc'

    @mcf_documents_error = @customer.mcf_documents.not_processable.order(order_by => direction).page(params[:page]).per(20)
    render :show_mcf_errors
  end

  def retake_mcf_errors
    if params[:confirm_unprocessable_mcf].present?
      confirm_unprocessable_mcf
    elsif params[:retake_mcf_documents].present?
      retake_mcf_documents
    end

    redirect_to show_mcf_errors_organization_customer_path(@organization, @customer)
  end

  def update_mcf
    if @customer.update(mcf_params)
      flash[:success] = 'Modifié avec succès.'
      redirect_to organization_customer_path(@organization, @customer, tab: 'mcf')
    else
      render :edit_mcf
    end
  end

  private

  def verify_rights
    unless @user.leader? || @user.manage_customers
      flash[:error] = t('authorization.unessessary_rights')
      redirect_to organization_path(@organization)
    end
  end

  def mcf_params
    params.require(:user).permit(:mcf_storage)
  end

  def retake_mcf_documents
    mcf_documents_errors = @customer.mcf_documents.where(id: params[:mcf_documents_ids])
    if mcf_documents_errors.any?
      mcf_documents_errors.each(&:reset)
      flash[:success] = 'Récupération en cours...'
    end
  end

  def confirm_unprocessable_mcf
    unprocessable_mcf = @customer.mcf_documents.where(id: params[:mcf_documents_ids]).not_processable
    if unprocessable_mcf.any?
      unprocessable_mcf.each(&:confirm_unprocessable)
      flash[:success] = 'Modifié avec succès.'
    else
      flash[:error] = 'Impossible de traiter la demande.'
    end
  end

  def load_customer
    @customer = customers.find(params[:id])
  end
end