# frozen_string_literal: true
class RetrieverParameters::BanksSelectionController < RetrieverController
  before_action :verif_account
  append_view_path('app/templates/front/retriever_parameters/views')

  def index
    @retrievers = @account.retrievers

    if bank_account_contains && bank_account_contains[:retriever_budgea_id]
      retriever = @account.retrievers.find_by_budgea_id(bank_account_contains[:retriever_budgea_id])
      retriever.ready if retriever&.waiting_selection?

      @retrievers = retriever ? [retriever] : []
    end

    @bank_accounts = @retrievers.collect(&:bank_accounts).flatten! || []

    render partial: 'banks_selection', locals: { bank_accounts: @bank_accounts }
  end

  private

  def bank_account_contains
    search_terms(params[:bank_account_contains])
  end
  helper_method :bank_account_contains

  def bank_account_ids
    params[:bank_account_ids].reject(&:blank?)
  end
end