# frozen_string_literal: true
class AccountingPlans::ConterpartAccountController < CustomerController
  before_action :load_customer

  prepend_view_path('app/templates/front/accounting_plans/views')

  def accounts_list
    if params[:type] == 'customer'
      _accounts = @customer.conterpart_accounts.customer
    else
      _accounts = @customer.conterpart_accounts.provider
    end

    accounts = _accounts.map{|account| { id: account.id, name: account.name, number: account.number } }

    render json: { accounts: accounts }, status: 200
  end

  def edit
    @conterpart_account      = @customer.conterpart_accounts.where(id: params[:id].to_i).first || ConterpartAccount.new
    @conterpart_account.kind = params[:kind].presence || 'provider'

    if params[:kind] == 'customer'
      accounting_plan_items   = @customer.accounting_plan.active_customers
    else
      accounting_plan_items   = @customer.accounting_plan.active_providers
    end

    @accounting_plan_items = accounting_plan_items.map{ |account| ["#{account.third_party_name} - #{account.third_party_account}", account.id] }
    
    render partial: 'edit'
  end

  def update
    @conterpart_account = @customer.conterpart_accounts.where(id: params[:conterpart_account][:id].to_i).first || ConterpartAccount.new

    @conterpart_account.user            = @customer
    @conterpart_account.accounting_plan = @customer.accounting_plan

    @conterpart_account.assign_attributes(_params)

    if @conterpart_account.save
      if @conterpart_account.is_default
        _kind = @conterpart_account.kind == 'customer' ? 'active_customers' : 'active_providers'
        @conterpart_account.update( accounting_plan_items: @customer.accounting_plan.send(_kind.to_sym) )
      else
        @conterpart_account.update( accounting_plan_items: AccountingPlanItem.where(id: params[:conterpart_account].try(:[], :accounting_plan_items)) )
      end

      json_flash[:success] = 'Mise à jour effectué.'
    else
      json_flash[:error]  = errors_to_list(@conterpart_account)
    end

    render json: { json_flash: json_flash }, status: 200
  end

  def delete
    if params[:id] == 'all-provider'
      @customer.conterpart_accounts.provider.destroy_all
    elsif params[:id] == 'all-customer'
      @customer.conterpart_accounts.customer.destroy_all
    else
      @conterpart_account = @customer.conterpart_accounts.where(id: params[:id].to_i).first
      @conterpart_account.try(:destroy)
    end

    render json: { json_flash: { success: 'Supprimer avec succès.' } }, status: 200
  end

  private

  def _params
    params.require(:conterpart_account).permit(:name, :number, :kind, :is_default)
  end

  def load_customer
    @customer = customers.find params[:customer_id]
  end
end