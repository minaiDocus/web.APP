class PonctualScripts::FillDeliveryAndExportState < PonctualScripts::PonctualScript
  def self.execute(date='2022-03-01')
    new({date: date}).run
  end

  private

  def execute
    preseizures = Pack::Report::Preseizure.where('created_at > ?', Date.parse("#{@options[:date]} 00:00:00"))
    total       = preseizures.size

    p total

    preseizures.each_with_index do |preseizure, index|
      sleep(5) if (index % 1000) == 0

      user = preseizure.user

      
      preseizure.delivery_state = 'not_delivered' if user.uses_api_softwares?
      if preseizure.is_delivered_to.present? || preseizure.delivery_message.to_s.match(/already sent/) || preseizure.pre_assignment_deliveries.where(state: 'sent').size > 0
        preseizure.delivery_state = preseizure.is_delivered_to.presence || 'ibiza'
      elsif preseizure.pre_assignment_deliveries.last.present?
        preseizure.delivery_state = 'failed'
      end

      
      preseizure.export_state = 'not_exported' if user.uses_non_api_softwares?
      export                  = preseizure.pre_assignment_exports.where(state: 'generated').last
      preseizure.export_state = export.for if export

      p "===#{index} / #{total}===="
      preseizure.save
    end
  end
end