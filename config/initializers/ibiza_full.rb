config_file = File.join(Rails.root, 'config', 'ibiza_full.yml')
raise 'Ibiza (Full) configuration file config/ibiza_full.yml is missing.' unless File.exist?(config_file)

class IbizaFullConf
  cattr_accessor :domain, :client_id, :client_secret

  class << self
    def config=(new_config)
      @@domain        = new_config['domain']        if new_config['domain']
      @@client_id     = new_config['client_id']     if new_config['client_id']
      @@client_secret = new_config['client_secret'] if new_config['client_secret']
    end
  end
end

IbizaFullConf.config = YAML::load_file(config_file)[Rails.env]
