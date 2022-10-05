class Jedeclare::ImportTransactionsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :cedricom, retry: false

  def perform
    UniqueJobs.for 'ImportTransactions' do
      Jedclare::ImportTransactions.perform
    end
  end
end