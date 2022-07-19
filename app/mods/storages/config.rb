module StoragesMod; end

#require extended module
  # require "#{Rails.root}/app/mods/billing/models/organization_module.rb"
  # require "#{Rails.root}/app/mods/billing/models/user_module.rb"

# Dir.glob("#{Rails.root}/app/mods/storages/libs/*/*.{rb}").each { |file| require file }

Idocus::Application.config.autoload_paths += Dir["#{Rails.root}/app/mods/storages/libs"]
Idocus::Application.config.autoload_paths += Dir["#{Rails.root}/app/mods/storages/services/export"]
Idocus::Application.config.autoload_paths += Dir["#{Rails.root}/app/mods/storages/services/import"]