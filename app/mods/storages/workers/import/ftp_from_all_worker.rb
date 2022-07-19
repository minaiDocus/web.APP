class StoragesMod::Import::FtpFromAllWorker
  include Sidekiq::Worker
  sidekiq_options queue: :file_import, retry: false

  def perform
    UniqueJobs.for 'ImportFromAllFTP' do
      Ftp.importable.each do |ftp|
        StoragesMod::Import::Ftp.delay.process ftp.id
      end
      true
    end
  end
end
