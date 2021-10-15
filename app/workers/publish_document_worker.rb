class PublishDocumentWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, unique: :until_and_while_executing

  def perform
    TempPack.not_processed.order(updated_at: :asc).limit(5).each do |temp_pack|
      DataProcessor::TempPack.delay.process(temp_pack.name)
    end
  end
end