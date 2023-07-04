# -*- encoding : UTF-8 -*-
module CegidCfeLib
  class DataSender
    def initialize(delivery)
      @delivery = delivery
    end

    def execute
      cegid_config = @delivery.user.organization.cegid_cfe

      begin
        ftp_path = "#{cegid_config.ftp_inbound_path}/#{@delivery.cloud_content.filename}"

        response = Net::FTP.open(cegid_config.ftp_server, username: cegid_config.ftp_username, password: cegid_config.ftp_password, ssl: {:verify_mode => OpenSSL::SSL::VERIFY_NONE}) do |ftp|
           ftp.putbinaryfile(@delivery.cloud_content.download, ftp_path)
        end

        { success: true, response: response }
      rescue => e
        { success: false, error: e || 'Unknown error ...' }
      end
    end
  end
end





#Net::FTP.new("217.182.143.165", username: "cfe", password: "fe39u3DEE!!!", ssl: {:verify_mode => OpenSSL::SSL::VERIFY_NONE})