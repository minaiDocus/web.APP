class StoragesMod::Import::DropboxWorker
  include Sidekiq::Worker
  sidekiq_options queue: :file_import, retry: false

  def perform
    UniqueJobs.for 'ImportFromDropbox' do
      StoragesMod::Import::Dropbox.check
    end
  end
end