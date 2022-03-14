class Management::Package < ApplicationRecord
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
    Package::Pricing.human_name_of(self.name)
  end

  def options
    Package::Pricing.options_of(self.name)
  end

  def base_price
    Package::Pricing.price_of(self.name)
  end

  def flow_limit
    Package::Pricing.flow_limit_of(self.name)
  end

  def excess_price
    Package::Pricing.flow_limit_of(self.name)
  end

  def excess_duration
    Package::Pricing.excess_duration_of(self.name)
  end

  def commitment_duration
    Package::Pricing.excess_duration_of(self.name)
  end
end