module V2::Organization
  extend ActiveSupport::Concern

  included do
    has_many :billings, class_name: 'Finance::Billing', as: :owner
  end

  def total_billing_of(period)
    self.billings.of_period(period).select("SUM(price) as price").first.price.to_i
  end
end