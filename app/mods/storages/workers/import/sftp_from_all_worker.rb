class StoragesMod::Import::SftpFromAllWorker
  include Sidekiq::Worker
  sidekiq_options queue: :file_import, retry: false

  def perform
    UniqueJobs.for 'ImportFromAllSFTP' do
      Sftp.importable.each do |sftp|
        StoragesMod::Import::Sftp.delay.process sftp.id
      end
      true
    end
  end
end
