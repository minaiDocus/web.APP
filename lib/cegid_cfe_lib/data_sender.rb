# -*- encoding : UTF-8 -*-
module CegidCfeLib
  class DataSender
    def initialize(delivery)
      @delivery = delivery
    end

    def execute(json_data)
      cegid_config = delivery.user.organization.cegid_cfe

      response = Net::FTP.new(cegid_config.ftp_server, username: cegid_config.ftp_username, password: cegid_config.ftp_password, ssl: {:verify_mode => OpenSSL::SSL::VERIFY_NONE}) do |ftp|
        ftp.putbinaryfile(delivery.cloud_content.download, "#{cegid_config.ftp_inbound_path}/#{delivery.cloud_content.filename}")
      end

      

      if response[:status] == "error"
        { success: false, error: response[:body].try(:[], 'message') || 'Unknown error ...' }
      else
        { success: true, response: response }
      end
    end
  end
end





#Net::FTP.new("217.182.143.165", username: "cfe", password: "fe39u3DEE!!!", ssl: {:verify_mode => OpenSSL::SSL::VERIFY_NONE})