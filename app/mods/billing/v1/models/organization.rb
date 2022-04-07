module BillingMod::V1::Organization
  extend ActiveSupport::Concern

  included do
    has_many :billings, class_name: 'BillingMod::V1::Billing', as: :owner
    has_many :extra_orders, class_name: 'BillingMod::V1::ExtraOrder', as: :owner
  end

  def total_billing_of(period)
    self.billings.of_period(period).select("SUM(price) as price").first.price.to_i
  end
end