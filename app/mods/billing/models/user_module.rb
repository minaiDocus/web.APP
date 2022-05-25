module BillingMod::UserModule
  extend ActiveSupport::Concern

  included do
    has_many :data_flows, class_name: 'BillingMod::DataFlow', dependent: :destroy
    has_many :packages, class_name: 'BillingMod::Package', dependent: :destroy
    has_many :billings, class_name: 'BillingMod::Billing', as: :owner
    has_many :extra_orders, class_name: 'BillingMod::ExtraOrder', as: :owner
  end

  def can_be_billed?
    return true if self.organization.invoice_created_customer

    (self.pieces.count > 0 || self.preseizures.count > 0)
  end

  def current_flow
    self.flow_of CustomUtils.period_of(Time.now)
  end

  def my_package
    self.packages.where('period <= ?', CustomUtils.period_of(Time.now)).order(period: :desc).limit(1).first
  end

  def is_package?(name)
    begin
      self.my_package.try(:name).to_s == name.to_s || ( self.my_package.respond_to?(name.to_sym) && self.my_package.send(name.to_sym) )
    rescue
      false
    end
  end

  def package_of(period)
    self.packages.of_period(period).first
  end

  def flow_of(period)
    package   = self.package_of(period)

    return nil if not package

    data_flow = self.data_flows.of_period(period).first || BillingMod::DataFlow.new

    data_flow.period = period
    data_flow.user   = self

    if package.excess_duration == 'annual' && !data_flow.persisted?
      max_version  = self.data_flows.select('MAX(period_version) as max_version').first.max_version.to_i
      data_flows   = self.data_flows.version(max_version).order(period: :desc)
      prev_package = self.packages.of_period(data_flows.first.try(:period)).first

      data_flow.period_version = (max_version > 0 && prev_package.try(:name) == package.name && data_flows.count < 12) ? max_version : (max_version + 1)
    end

    data_flow.save

    data_flow
  end

  def total_billing_of(period)
    self.billings.of_period(period).select("SUM(price) as price").first.price.to_f
  end
end