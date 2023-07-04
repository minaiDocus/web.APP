class PreAssignment::Builder::CegidCfeWorker
  include Sidekiq::Worker
  sidekiq_options unique: :until_and_while_executing

  def perform
    UniqueJobs.for 'PreAssignmentBuilderCegidCfeWorker' do
      PreAssignmentDelivery.cegid_cfe.pending.order(id: :asc).limit(200).each do |delivery|
        PreAssignment::Builder::CegidCfe::Launcher.delay(queue: :high).process(delivery.id)
      end
    end
  end

  class Launcher
    def self.process(delivery_id)
      UniqueJobs.for "PreAssignmentBuilderCegidCfeWorker-#{delivery_id}" do
        delivery = PreAssignmentDelivery.find(delivery_id)
        PreAssignment::Builder::CegidCfe.new(delivery).run if delivery.pending?
      end
    end
  end
end