class BillingMod::PrepareBillingsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :high, retry: false

  def perform
    UniqueJobs.for 'BillingMod::PrepareBillings' do
      organizations = Organization.billed.order(code: :asc)

      time = 10
      organizations.each do |organization|
        BillingMod::PrepareBillingsWorker::Launcher.delay_for(time.minutes).process(organization.id)
        time += 10 #Step every 10 minutes
      end
    end
  end

  class Launcher
    def self.process(organization_id)
      UniqueJobs.for "BillingMod::PrepareBilling-#{organization_id}" do
        organization = Organization.find organization_id

        next if not organization.can_be_billed?

        organization.customers.active_at(Time.now.end_of_month + 1.day).each do |customer|
          BillingMod::PrepareUserBilling.new(customer).execute
        end

        BillingMod::PrepareOrganizationBilling.new(organization).execute
      end
    end
  end
end
