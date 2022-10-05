class Jedeclare::FetchReceptionstWorker
  include Sidekiq::Worker
  sidekiq_options queue: :cedricom, retry: false

  def perform
    UniqueJobs.for 'FetchReceptions' do
      Jedeclare::FetchReceptions.fetch_missing_contents
    end
  end
end