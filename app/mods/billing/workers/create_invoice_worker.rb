class BillingMod::CreateInvoiceWorker
  include Sidekiq::Worker
  sidekiq_options queue: :high, retry: false

  def perform
    UniqueJobs.for 'BillinMod::CreateInvoice' do
      BillingMod::CreateInvoice.new.execute(nil, {notify: false, auto_upload: false})
    end
  end
end
