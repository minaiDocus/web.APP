class PreAssignment::Delivery::SageGecWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, unique: :until_and_while_executing

  def perform
    UniqueJobs.for 'PreAssignmentDeliverySageGecWorker' do
      PreAssignmentDelivery.sage_gec.data_built.order(id: :asc).limit(200).each do |delivery|
        PreAssignment::Delivery::SageGecWorker::Launcher.delay(queue: :high).process(delivery.id)
      end
    end
  end

  class Launcher
    def self.process(delivery_id)
      UniqueJobs.for "PreAssignmentDeliverySageGecWorker-#{delivery_id}" do
        delivery = PreAssignmentDelivery.find(delivery_id)
        PreAssignment::Delivery::SageGec.new(delivery).run if delivery.data_built?
      end
    end
  end
end