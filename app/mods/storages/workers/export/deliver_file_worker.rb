class StoragesMod::Export::DeliverFileWorker
  include Sidekiq::Worker
  sidekiq_options queue: :file_delivery, retry: false

  def perform(service_prefix)
    UniqueJobs.for "DeliverFile_to_#{service_prefix}" do
      StoragesMod::Export::DeliverFile.to service_prefix
    end
  end
end
