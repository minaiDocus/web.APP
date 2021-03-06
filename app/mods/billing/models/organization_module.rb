module BillingMod::OrganizationModule
  extend ActiveSupport::Concern

  included do
    has_many :billings, class_name: 'BillingMod::Billing', as: :owner
    has_many :extra_orders, class_name: 'BillingMod::ExtraOrder', as: :owner
  end

  def can_be_billed?
    !self.is_test && self.is_active && !self.is_for_admin
  end

  def total_billing_of(period)
    self.billings.of_period(period).select("SUM(price) as price").first.price.to_i
  end
end