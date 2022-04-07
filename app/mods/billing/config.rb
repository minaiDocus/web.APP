module BillingMod
  module V1; end
end

#require extended module
  require "#{Rails.root}/app/mods/billing/v1/models/invoice.rb"
  require "#{Rails.root}/app/mods/billing/v1/models/organization.rb"
  require "#{Rails.root}/app/mods/billing/v1/models/user.rb"

Idocus::Application.config.autoload_paths += Dir["#{Rails.root}/app/mods/billing/v1/libs"]
Idocus::Application.config.autoload_paths += Dir["#{Rails.root}/app/mods/billing/v1/services"]