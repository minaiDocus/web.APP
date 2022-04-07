class BillingMod::V1::Package < ApplicationRecord
  self.table_name = 'user_packages'

  belongs_to :user

  validates_presence_of :name, :period, :version

  scope :of_period, ->(period){ where(period: period.to_i) }

  def is_with_commitment?
    self.commitment_start_period.to_i > 0 && self.commitment_end_period.to_i > 0
  end

  def is_commitment_end?
    period = CustomUtils.period_of(Time.now)
    self.commitment_end_period.to_i = 0 || self.commitment_end_period <= period
  end

  def human_name
    BillingMod::V1::Configuration.human_name_of(self.name)
  end

  def options
    BillingMod::V1::Configuration.options_of(self.name)
  end

  def base_price
    BillingMod::V1::Configuration.price_of(self.name, self.user)
  end

  def flow_limit
    BillingMod::V1::Configuration.flow_limit_of(self.name)
  end

  def excess_price
    BillingMod::V1::Configuration.excess_price_of(self.name)
  end

  def excess_duration
    BillingMod::V1::Configuration.excess_duration_of(self.name)
  end

  def commitment_duration
    BillingMod::V1::Configuration.excess_duration_of(self.name)
  end
end