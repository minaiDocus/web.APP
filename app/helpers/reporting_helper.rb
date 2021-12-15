# frozen_string_literal: true

module ReportingHelper
  def accounts_options
    accounts.map do |account|
      [account.info, account.id]
    end
  end

  def accounts_repartition_stat(report)
    user = report.user

    journals         = AccountBookType.where(user_id: user.id).select(:anomaly_account, :account_number, :default_account_number)
    anomaly_accounts = []
    waiting_accounts = []
    default_accounts = []
    journals.each do |journal|
      anomaly_accounts << journal.anomaly_account  if journal.anomaly_account.present?
      waiting_accounts << journal.account_number   if journal.account_number.present?
      default_accounts << journal.default_account_number if journal.default_account_number.present?
    end

    preseizures_ids  = Pack::Report::Preseizure.where("created_at BETWEEN '#{@date_range.join("' AND '")}'").where(user_id: user.id, report_id: report.id).select(:id)

    anomaly_accounts_size = 0
    waiting_accounts_size = 0
    default_accounts_size = 0
    all_accounts    = Pack::Report::Preseizure::Account.where(preseizure_id: preseizures_ids).select(:number)

    all_accounts.each do |account|
      if anomaly_accounts.include?(account.number)
        anomaly_accounts_size += 1 
      elsif waiting_accounts.include?(account.number)
        waiting_accounts_size += 1
      elsif default_accounts.include?(account.number)
        default_accounts_size += 1
      end
    end

    { all_accounts_size: all_accounts.size, anomaly_accounts_size: anomaly_accounts_size, waiting_accounts_size: waiting_accounts_size, default_accounts_size: default_accounts_size }
  end
end