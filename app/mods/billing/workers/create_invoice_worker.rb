class BillingMod::CreateInvoiceWorker
  include Sidekiq::Worker
  sidekiq_options queue: :high, retry: false

  def perform
    UniqueJobs.for 'BillinMod::CreateInvoice' do
      BillingMod::CreateInvoicePdf.new.execute
    end
  end
end
