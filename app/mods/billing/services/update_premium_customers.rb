# -*- encoding : UTF-8 -*-
class BillingMod::UpdatePremiumCustomers
  def initialize(organization_code)
    @organization_code = organization_code
  end

  def execute
    list_customers = []
    organization   = Organization.find_by_code @organization_code

    organization.customers.active.each do |customer|
      current_package = customer.package_of(CustomUtils.period_of(Time.now))
      next_package    = customer.package_of(CustomUtils.period_of(1.month.after))

      if current_package
        update_(current_package)

        list_customers << customer.code
      end

      update_(next_package)    if next_package

      BillingMod::PrepareUserBilling.new(customer.reload).execute
    end

    list_customers
  end

  private

  def update_(package)
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