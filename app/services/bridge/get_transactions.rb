class Bridge::GetTransactions
  def initialize(user)
    @user = user
  end

  def execute(time=nil, _banks_ids=[])
    begin
      _fetch_time = time.present? ? time.to_date.beginning_of_day : nil
    rescue
      return "Paramètre invalide: Time: #{time}"
    end

    if @user.bridge_account
      access_token = Bridge::Authenticate.new(@user).execute

      bank_accounts = @user.bank_accounts.configured

      bank_accounts.each do |bank_account|
        next if _banks_ids.any? && !_banks_ids.include?(bank_account.id)

        if bank_account.operations.any?
          start_time = bank_account.operations.last.created_at.to_time
        else
          start_time = bank_account.start_date.try(:to_time) || bank_account.created_at.beginning_of_day
        end

        start_time = _fetch_time if _fetch_time.present?

        begin
          transactions = BridgeBankin::Transaction.list_by_account(account_id: bank_account.api_id, access_token: access_token, since: start_time)
        rescue
          transactions = []
        end

        transactions.each do |transaction|
          if transaction.date >= bank_account.start_date
            @operation = bank_account.operations.where(api_id: transaction.id, api_name: 'bridge').first || Operation.new(bank_account: bank_account, user: @user, organization: @user.organization)

            save_operation(transaction) unless @operation.persisted? || transaction.is_future || transaction.raw_description == 'Virement'
          end
        end
      end
    end
  end

  private

  def save_operation(transaction)
    @operation.date   = transaction.date
    @operation.amount = transaction.amount
    @operation.label  = @operation.bank_account.type_name == 'card' ? '[CB]' + transaction.raw_description : transaction.raw_description
    @operation.api_id = transaction.id
    @operation.api_name = 'bridge'
    @operation.value_date = transaction.date
    @operation.currency = case transaction.currency_code
                          when 'EUR'
                            @operation.currency = { id: 'EUR', symbol: '€', prefix: false, crypto: false, precision: 2, marketcap: nil, datetime: nil, name: 'Euro'}
                          when 'USD'
                            @operation.currency = { id: 'USD', symbol: '$', prefix: true, crypto: false, precision: 2, marketcap: nil, datetime: nil, name: 'US Dollar'}
                          when 'GBP'
                            @operation.currency = { id: 'GBP', symbol: '£', prefix: false, crypto: false, precision: 2, marketcap: nil, datetime: nil, name: 'British Pound Sterling'}
                          when 'CHF'
                            @operation.currency = { id: 'CHF', symbol: 'CHF', prefix: false, crypto: false, precision: 2, marketcap: nil, datetime: nil, name: 'Swiss Franc'}
                          when 'ZAR'
                            @operation.currency = { id: 'ZAR', symbol: 'R', prefix: false, crypto: false, precision: 2, marketcap: nil, datetime: nil, name: 'South African Rand'}
                          end

    @operation.save
  end
end