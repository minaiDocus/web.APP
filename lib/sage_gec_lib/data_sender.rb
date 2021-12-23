# -*- encoding : UTF-8 -*-
module SageGecLib
  class DataSender
    def initialize(delivery)
      @delivery = delivery
    end

    def execute(json_data)
      data = JSON.parse(json_data)

      client = SageGecLib::Api::Client.new

      data["attachment"] = Faraday::UploadIO.new(StringIO.new(@delivery.preseizures.first.piece.cloud_content.download), @delivery.preseizures.first.piece.cloud_content.content_type, "#{@delivery.preseizures.first.coala_piece_name}.pdf")

      date = @delivery.preseizures.first.date

      accountancy_practice_uuid = @delivery.user.organization.sage_gec&.sage_private_api_uuid
      company_uuid = @delivery.user.sage_gec&.sage_private_api_uuid

      periods  = client.get_periods_list(accountancy_practice_uuid, company_uuid)

      period = periods[:body].select { |p| Date.parse(p["startDate"]) <= date && Date.parse(p["endDate"]) >= date }.first

      post_body = { "entry": JSON.dump(data["entry"]), "attachment" => data["attachment"] }

      response = client.send_pre_assignment(accountancy_practice_uuid, company_uuid, period["$uuid"], post_body)

      if response["type"] == "O"
        { success: true, response: response }
      else
        { error: response['message'] }
      end
    end
  end
end