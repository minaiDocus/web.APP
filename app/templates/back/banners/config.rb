module Admin
  module Banners; end
end

Idocus::Application.config.autoload_paths += Dir["#{Rails.root}/templates/back/banners/controllers"]