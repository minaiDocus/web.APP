class BillingMod::Package < ApplicationRecord
  self.table_name = 'user_packages'

  belongs_to :user
  # Workarround belongs to user doesn't work
  # def user
  #   User.where(id: self.user_id).first
  # end

  validates :journal_size, numericality: { greater_than_or_equal_to: 5, less_than_or_equal_to: 30 }
  validates_presence_of :name, :period

  scope :of_period, ->(period){ where(period: period.to_i) }
  scope :by_period, ->{ order(period: :desc) }

  def is_with_commitment?
    self.commitment_start_period.to_i > 0 && self.commitment_end_period.to_i > 0
  end

  def is_commitment_end?
    period = CustomUtils.period_of(Time.now)
    self.commitment_end_period.to_i == 0 || self.commitment_end_period <= period
  end

  def human_name
    BillingMod::Configuration.human_name_of(self.name)
  end

  def options
    BillingMod::Configuration.options_of(self.name)
  end

  def base_price
    BillingMod::Configuration.price_of(self.name, self.user)
  end

  def flow_limit
    BillingMod::Configuration.flow_limit_of(self.name)
  end

  def excess_price
    BillingMod::Configuration.excess_price_of(self.name)
  end

  def excess_duration
    BillingMod::Configuration.excess_duration_of(self.name)
  end

  def commitment_duration
    BillingMod::Configuration.excess_duration_of(self.name)
  end
end