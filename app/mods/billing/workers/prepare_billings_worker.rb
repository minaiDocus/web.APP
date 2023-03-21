class BillingMod::PrepareBillingsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :high, retry: false

  def perform
    UniqueJobs.for 'BillingMod::PrepareBillings' do
      today = Time.now.strftime('%w').to_i

      BillingMod::CreateInvoice.launch_test if (today % 2) == 0
    end
  end
end
