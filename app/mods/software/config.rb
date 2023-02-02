module SoftwareMod; end

#require extended module
  #require "#{Rails.root}/app/mods/software/models/organization_module.rb"
  #require "#{Rails.root}/app/mods/software/models/user_module.rb"

Idocus::Application.config.autoload_paths += Dir["#{Rails.root}/app/mods/software/services"]