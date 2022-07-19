class StoragesMod::Import::McfWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: false

  def perform
    UniqueJobs.for 'McfProcessor' do
      StoragesMod::Import::Mcf.execute
    end
  end
end