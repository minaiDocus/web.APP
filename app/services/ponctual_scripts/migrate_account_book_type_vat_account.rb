class PonctualScripts::MigrateAccountBookTypeVatAccount < PonctualScripts::PonctualScript
  def self.execute()
    new().run
  end

  def self.rollback
    new().rollback
  end

  private

  def execute
    journals = AccountBookType.all

    logger_infos "Journals count: #{journals.count}"

    journals.each do |journal|
      vat_account     = journal.vat_account.present? ? journal.vat_account : ''
      vat_account_10  = journal.vat_account_10.present? ? journal.vat_account_10 : ''
      vat_account_8_5 = journal.vat_account_8_5.present? ? journal.vat_account_8_5 : ''
      vat_account_5_5 = journal.vat_account_5_5.present? ? journal.vat_account_5_5 : ''
      vat_account_2_1 = journal.vat_account_2_1.present? ? journal.vat_account_2_1 : ''

      journal.update(vat_accounts: {'0': vat_account, '10': vat_account_10, '8.5': vat_account_8_5, '5.5': vat_account_5_5, '2.1': vat_account_2_1}.to_json)
    end

    logger_infos "Migrate AccountBookType vat_accounts done."
  end

  def backup; end

end
