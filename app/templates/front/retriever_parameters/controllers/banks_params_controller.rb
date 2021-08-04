# frozen_string_literal: true
class RetrieverParameters::BanksParamsController < RetrieverController
  before_action :verif_account
  append_view_path('app/templates/front/retriever_parameters/views')

  def index
    @bank_accounts = []

    if params[:bank_account_contains].present?
      # @bank_accounts = @account.bank_accounts.used
      @bank_accounts = @account.bank_accounts ###FOR TEST
      @bank_accounts = @bank_accounts.where('bank_name LIKE ?', "%#{search_by('bank_name')}%") if search_by('bank_name').present?
      @bank_accounts = @bank_accounts.where('name LIKE ?', "%#{search_by('name')}%") if search_by('name').present?
      @bank_accounts = @bank_accounts.where('number LIKE ?', "%#{search_by('number')}%") if search_by('number').present?
      @bank_accounts = @bank_accounts.where('journal LIKE ?', "%#{search_by('journal')}%") if search_by('journal').present?
      @bank_accounts = @bank_accounts.where('accounting_number LIKE ?', "%#{search_by('accounting_number')}%") if search_by('accounting_number').present?
    end

    render partial: 'banks_params', locals: { bank_accounts: @bank_accounts }
  end

  private

  def search_by(field)
    params[:bank_account_contains].try(:[], field)
  end
end