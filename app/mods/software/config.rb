module SoftwareMod
  module Service; end
end

#require extended module
  require "#{Rails.root}/app/mods/software/models/concerns/organization_module.rb"
  require "#{Rails.root}/app/mods/software/models/concerns/user_module.rb"
  require "#{Rails.root}/app/mods/software/models/concerns/owned_softwares.rb"
  require "#{Rails.root}/app/mods/software/models/concerns/configuration.rb"

Dir.glob("#{Rails.root}/app/mods/software/services/softwares/*.rb").each { |file| require file }

Idocus::Application.config.autoload_paths += Dir["#{Rails.root}/app/mods/software/services"]