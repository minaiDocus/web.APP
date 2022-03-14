module V2::Organization
  extend ActiveSupport::Concern

  included do
    has_many :billings, as: :owner
  end

  def total_billing_of(period)
    self.billings.of_period(period).select("SUM(price) as price").first.price
  end
end