class PonctualScripts::CreateCustomerViaCsv
  def initialize(file_path, requester_code)
    @file_path      = file_path
    @requester_code = requester_code
  end

  def execute
    data_errors = []
    data_file = File.read(@file_path)

    user      = User.find_by_code @requester_code
    requester = Collaborator.new(user)

    data_file.each_line do |line|
      data = line.split(";")

      organization = Organization.find_by_code data[0]
      user_params  = {company: data[1], code: data[2], first_name: data[3], last_name: data[4], phone_number: data[5], email: data[6] }

      customer = Subscription::CreateCustomer.new(organization, requester, user_params, nil, nil).execute if organization && requester

      params_subscription = {subscription_option: "ido_classique", number_of_journals: 5, is_pre_assignment_active: 'true'}

      if organization && customer.persisted?
        Subscription::Form.new(customer.subscription, requester, nil).submit(params_subscription)
      else
        data_errors << { code: data[2], message: customer.try(:errors).try(:messages) }
      end
    end

    p data_errors
  end 
end