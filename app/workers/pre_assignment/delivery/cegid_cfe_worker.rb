class PreAssignment::Delivery::CegidCfeWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, unique: :until_and_while_executing

  def perform
    UniqueJobs.for 'PreAssignmentDeliveryCegidCfeWorker' do
      PreAssignmentDelivery.cegid_cfe.data_built.order(id: :asc).limit(200).each do |delivery|
        PreAssignment::Delivery::CegidCfeWorker::Launcher.delay(queue: :high).process(delivery.id)
      end
    end
  end

  class Launcher
    def self.process(delivery_id)
      UniqueJobs.for "PreAssignmentDeliveryCegidCfeWorker-#{delivery_id}" do
        delivery = PreAssignmentDelivery.find(delivery_id)
        PreAssignment::Delivery::CegidCfe.new(delivery).run if delivery.data_built?
      end
    end
  end
end