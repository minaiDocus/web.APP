module SoftwareMod
  module Service; end
end

#require extended module
  #require "#{Rails.root}/app/mods/software/models/organization_module.rb"
  #require "#{Rails.root}/app/mods/software/models/user_module.rb"

Dir.glob("#{Rails.root}/app/mods/software/services/softwares/*.rb").each { |file| require file }

Idocus::Application.config.autoload_paths += Dir["#{Rails.root}/app/mods/software/services"]