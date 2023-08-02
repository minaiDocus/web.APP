class PreAssignment::Delivery::CegidCfe < PreAssignment::Delivery::DataService
  def self.retry_delivery(delivery_id, retry_count)
    delivery = PreAssignmentDelivery.find delivery_id

    delivery.update(state: 'pending', error_message: "retry_sending_#{retry_count}") if delivery.state == 'error'
  end

  def self.execute(delivery)
    new(delivery).run
  end

  def initialize(delivery)
    super
  end

  private

  def execute
    @delivery.sending
    @previous_error = @delivery.error_message

    if @delivery.preseizures.select{|pres| pres.pre_assignment_deliveries.where(state: 'sent').count > 0 }.size > 0
      #handle_delivery_success
    else
      begin
        response = CegidCfeLib::DataSender.new(@delivery).execute

        if response[:error].present?
          handle_delivery_error(response[:error])

          #DONT ACTIVATE RETRY SENDING DELIVERY
          #retry_sending
        else
          #handle_delivery_success
        end
      rescue => e


        handle_delivery_error 'Internal service error!'

        #retry_sending
      end
    end

    @delivery.sent?
  end

  def retry_sending
    retry_count  = @previous_error.gsub('retry_sending_', '').to_i
    retry_count += 1

    PreAssignment::Delivery::CegidCfe.delay_for(1.hours, queue: :default).retry_delivery(@delivery.id, retry_count) if retry_count <= 3
  end
end