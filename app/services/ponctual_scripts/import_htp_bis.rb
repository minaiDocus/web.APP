class ImportHtpBis
  def self.execute(path)
    data = CSV.parse(File.open(path), col_sep: ';')

    organization = Organization.find_by_code('HTP')

    requester = Member.find_by_code("HTP%TP")

    data.each do |d|
      group = d[0]
      company = d[3]
      registration_number = d[2]
      code = "HTP%#{d[1]}".upcase
      full_name = "Non fourni"
      iban = d[4].gsub!(' ', '')
      bic = d[5]
      account_number = d[6]
      ledger = d[7]

      email = "htp+#{d[1]}@idocus.com"      

      params = { code: code, registration_number: registration_number, company: company, manager: requester, organization: organization, 
                 first_name: full_name.split(' ')[0], last_name: full_name.split(' ')[1], email: email }

      customer = User.find_by_code(code)

      customer = Subscription::CreateCustomer.new(organization, Collaborator.new(requester.user), params, requester.user, nil).execute unless customer

      if customer
        create_package = BillingMod::CreatePackage.new(customer, 'ido_retriever', {number_of_journals: 5 }, true, requester.user).execute
        BillingMod::PrepareUserBilling.new(customer.reload).execute
      end

      if customer
        customer.account_book_types.find_or_create_by(name: ledger, pseudonym: ledger, description: ledger, currency: 'EUR', entry_type: 4)
        customer.bank_accounts.find_or_create_by(bank_name: bic, name: company, number: iban, bic: bic, journal: ledger, ebics_enabled_starting: '2022-09-07', 
                                      accounting_number: account_number, temporary_account: '471000', is_used: true, start_date: '2022-09-07', api_name: 'idocus')
      end
    end
  end
end


