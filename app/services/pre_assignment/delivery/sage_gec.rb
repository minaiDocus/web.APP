class PreAssignment::Delivery::SageGec < PreAssignment::Delivery::DataService
  def self.execute(delivery)
    new(delivery).run
  end

  def initialize(delivery)
    super
  end

  private

  def execute
    @delivery.sending

    if @delivery.preseizures.select{|pres| pres.is_delivered? }.size > 0
      handle_delivery_success
    else
      begin
        send_data = SageGecLib::DataSender.new(@delivery)
        response  = send_data.execute(@delivery.cloud_content.download)

        if response[:error].present?
          handle_delivery_error(response[:error])
        else
          handle_delivery_success
        end
      rescue => e
        log_document = {
          name: "PreAssignment::Delivery::sage_gec",
          error_group: "[pre-assignment-delivery-sage_gec] active storage can't read file",
          erreur_type: "Active Storage, can't read file",
          date_erreur: Time.now.strftime('%Y-%M-%d %H:%M:%S'),
          more_information: {
            delivery: @delivery.inspect,
            error: e.to_s
          }
        }
        ErrorScriptMailer.error_notification(log_document).deliver

        ##WORKAROUND : Retry sending is blocked, don't retry
        handle_delivery_error 'Internal service error!'

        # if pending_message == 'limit pending reached'
        #   handle_delivery_error pending_message
        # else
        #   @delivery.update(state: 'pending', error_message: pending_message )
        # end
      end
    end

    @delivery.sent?
  end
end