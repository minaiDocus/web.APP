class BillingMod::CreateInvoiceWorker
  include Sidekiq::Worker
  sidekiq_options queue: :high, retry: false

  def perform
    UniqueJobs.for 'BillinMod::CreateInvoice' do
      BillingMod::CreateInvoice.new(nil, {notify: true, auto_upload: true}).execute
      sleep(500)
      BillingMod::CreateInvoice.launch_test
    end
  end
end
