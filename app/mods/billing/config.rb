module BillingMod; end

#require extended module
  require "#{Rails.root}/app/mods/billing/models/organization.rb"
  require "#{Rails.root}/app/mods/billing/models/user.rb"

Idocus::Application.config.autoload_paths += Dir["#{Rails.root}/app/mods/billing/libs"]
Idocus::Application.config.autoload_paths += Dir["#{Rails.root}/app/mods/billing/services"]