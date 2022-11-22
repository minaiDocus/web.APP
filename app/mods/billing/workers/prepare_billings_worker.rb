class BillingMod::PrepareBillingsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :high, retry: false

  def perform
    UniqueJobs.for 'BillingMod::PrepareBillings' do
      sunday = Time.now.strftime('%w')

      if sunday
        organizations = Organization.client.active

        organizations.each_with_index do |organization, _index|
          organization.customers.active_at(Time.now.end_of_month + 1.day).each do |customer|
            BillingMod::PrepareUserBilling.new(customer).execute
          end

          BillingMod::PrepareOrganizationBilling.new(organization).execute

          sleep 10 if (_index % 30) == 0
        end
      end
    end
  end
end
