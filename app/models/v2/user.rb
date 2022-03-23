module V2::User
  extend ActiveSupport::Concern

  included do
    has_many :data_flows, class_name: 'Management::DataFlow', dependent: :destroy
    has_many :packages, class_name: 'Management::Package', dependent: :destroy
    has_many :billings, class_name: 'Finance::Billing', as: :owner
  end

  def current_flow
    self.flow_of CustomUtils.period_of(Time.now)
  end

  def current_package
    self.package_of CustomUtils.period_of(Time.now)
  end

  def package_of(period)
    self.packages.of_period(period).first
  end

  def flow_of(period)
    data_flow = self.data_flows.of_period(period).first || Management::DataFlow.new

    data_flow.period = period
    data_flow.user   = self
    data_flow.save

    data_flow
  end

  def total_billing_of(period)
    self.billings.of_period(period).select("SUM(price) as price").first.price.to_i
  end
end