class PonctualScripts::CreateCustomerViaCsv
  def initialize(file_path, requester_code)
    @file_path      = file_path
    @requester_code = requester_code
  end

  def execute
    data_errors = []
    data_bank   = []
    data_file   = File.read(@file_path)

    user      = User.find_by_code(@requester_code)
    requester = Collaborator.new(user)
    match_bank_name = BankAccount.all.collect(&:bank_name).uniq

    data_file.each_line do |line|
      data = line.split(",")

      organization = Organization.find_by_code(data[1].split('%')[0]).presence
      user_params  = { company: data[2], code: data[1], first_name: data[4], last_name: data[3], phone_number: data[9], email: data[10] }

      customer = Subscription::CreateCustomer.new(organization, requester, user_params, nil, nil).execute if organization && requester

      params_subscription = {subscription_option: "ido_plus_micro", number_of_journals: 5, is_pre_assignment_active: 'true', retriever_option: 'true' }

      if organization && customer.persisted?
        Subscription::Form.new(customer.subscription, requester, nil).submit(params_subscription)

        bank_account = BankAccount.new

        bank_name = ''
        match_bank_name.each{ |_name| bank_name = _name if bank_name.blank? && data[13].downcase.include?(_name.tr('éèếÉ', 'eee').downcase) }

        bank_account.user              = customer
        bank_account.api_name          = 'idocus'
        bank_account.bank_name         = bank_name
        bank_account.name              = data[13]
        bank_account.number            = data[11]
        bank_account.journal           = data[15]
        bank_account.currency          = data[12]
        bank_account.accounting_number = data[14]
        bank_account.temporary_account = "471000"
        bank_account.start_date        = data[16].gsub(/\n/, '')
        bank_account.is_used           = true

        data_bank << { csv: data[13], base: bank_name.titleize }  if !bank_name.blank? && bank_name.downcase != data[13].downcase

        if not bank_account.save
          data_errors << { code: data[2], error_bank_message: bank_account.try(:errors).try(:messages) }
        end
      else
        data_errors << { code: data[2], message: customer.try(:errors).try(:messages) }
      end
    end

    send_mail_for(data_bank, data_errors )
    p data_errors
  end 

  private

  def send_mail_for(data_bank, data_errors)
    lines = []
    data_bank.each do |data|
      lines << data.join(';')
    end

    CustomUtils.mktmpdir('create_customers_via_csv', nil, false) do |dir|
      file_path = File.join(dir, "create_customers_via_csv.csv")

      File.write(file_path, lines.join("\n"));

      log_document = {
        subject: "[CreateCustomerViaCsv] creation dossier via CSV",
        name: "CreateCustomerViaCsv",
        error_group: "[CreateCustomerViaCsv] creation dossier via CSV",
        erreur_type: "[CreateCustomerViaCsv] - creation dossier via CSV",
        date_erreur: Time.now.strftime('%Y-%m-%d %H:%M:%S'),
        more_information: {
          data_errors: data_errors.to_json
        }
      }

      begin
        ErrorScriptMailer.error_notification(log_document, { attachements: [{name: "create_customers_via_csv.csv", file: File.read(file_path)}]} ).deliver
      rescue
        ErrorScriptMailer.error_notification(log_document).deliver
      end

      p file_path
    end
  end
end