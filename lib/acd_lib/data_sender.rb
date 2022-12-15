# -*- encoding : UTF-8 -*-
module AcdLib
  class DataSender
    def initialize(delivery)
      @delivery = delivery
    end

    def execute(json_data)
      data = JSON.parse(json_data)

      client = AcdLib::Api::Client.new

      company_code = @delivery.user.acd&.code

      client.set_company(company_code)

      retry_count = 0
      preseizure = @delivery.preseizures.first
      begin
        if preseizure.piece

          attachment_data = {}

          retry_count += 1
          file_path = preseizure.piece.cloud_content_object.path
          sleep(1)


          attachment_data["idArboged"] = 0
          attachment_data["file"] = Faraday::UploadIO.new(StringIO.new(File.read(file_path)), preseizure.piece.cloud_content.content_type, "#{preseizure.coala_piece_name}.pdf")

          file = client.store_file(attachment_data)
          data["referenceGED"] = file[:body]["id"]
        else
          data["referenceGED"] = ""
        end
      rescue => e
        if retry_count <= 3
          sleep(5)

          retry
        else
          raise e
        end
      end
      

      if period
        response = client.send_pre_assignment(data)

        if response[:status] == "error"
          { success: false, error: response[:body].try(:[], 'listeErreurs') || 'Unknown error ...' }
        else
          { success: true, response: response }
        end
      else
        { error: "Erreur de communication avec l'API ACD" }
      end
    end
  end
end