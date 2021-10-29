class Transaction::DestroyBankAccounts
  def initialize(bank_accounts)
    @bank_accounts = bank_accounts
  end

  def execute(reason=nil)
    @bank_accounts.each do |bank_account|
      bank_account.is_used = false
      bank_account.save

      # bank_account.destroy unless bank_account.reload.retriever
    end

    log_document = {
      subject: "[Transaction::DestroyBankAccounts] - Destroying bank accounts",
      name: "DestroyBankAccounts",
      error_group: "[Destroy Banks] : Destroying banks",
      erreur_type: "Destroying banks",
      date_erreur: Time.now.strftime('%Y-%m-%d %H:%M:%S'),
      more_information: {
      	banks: @bank_accounts.collect(&:id),
      	reason: reason.to_s
      }
    }

    ErrorScriptMailer.error_notification(log_document).deliver
  end
end
