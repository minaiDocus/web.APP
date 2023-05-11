# -*- encoding : UTF-8 -*-
class DataVerificator::CheckIdoPremiumDocuments < DataVerificator::DataVerificator
  def execute

    messages = []
    non_premium_found = 0

    BillingMod::Configuration::PREMIUM.each do |key, value|
      organization = Organization.find_by_code key

      if organization
        active_customers = organization.customers.active_at(Time.now)

        active_customers.each do |customer|
          current_package = customer.package_of(CustomUtils.period_of(Time.now))
          if current_package.name != 'ido_premium'
            non_premium_found += 1
            update(current_package)
            messages << "customer_code: #{customer.code}, package_id: #{current_package.id}, package_name: #{current_package.name}"
          else
            puts "no premium found"
          end

        end

      else
        puts "organization nil"
      end
    end

    {
      title: "Non premium packages found : #{non_premium_found}",
      type: "table",
      message: messages.join('; ')
    }

  end 

  def update(package)
    package.name = "ido_premium"

    package.preassignment_active = true
    package.upload_active        = true
    package.bank_active          = true
    package.scan_active          = true

    package.commitment_start_period = 0
    package.commitment_end_period   = 0

    package.save
  end
end