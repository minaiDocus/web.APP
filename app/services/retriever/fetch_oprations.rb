# -*- encoding : UTF-8 -*-
class Retriever::FetchOperations
  def self.execute
    users    = BankAccount.used.budgea.collect(&:user).uniq
    min_date = 2.days.ago.strftime('%Y-%m-%d')
    max_date = Time.now.strftime('%Y-%m-%d')
    results  = []

    users.each do |user|
      results << DataProcessor::RetrievedData.new(nil, '', user).execute_with('operation', user.bank_accounts.collect(&:api_id), min_date, max_date) if user.still_active? && user.try(:budgea_account).try(:access_token).present? && user.bank_accounts.collect(&:retriever).any?
      results << "\n+++++++++++++++++++++++++++++\n"
    end

    mail_result = {
      name: "FetchOperations",
      date_fetch: Time.now.strftime('%Y-%m-%d %H:%M:%S'),
      details: results.join("<br>")
    }

    FetchOperationsMailer.notify(mail_result).deliver
  end
end