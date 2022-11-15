module Admin
  module BankUtilities; end
end

Idocus::Application.config.autoload_paths += Dir["#{Rails.root}/templates/back/bank_utilities/controllers"]