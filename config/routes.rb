require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  mount Ckeditor::Engine => '/ckeditor'
  root to: 'account/account#index'

  wash_out :dematbox

  devise_for :users

  authenticate :user, lambda { |u| u.is_admin } do
    mount Sidekiq::Web => '/sidekiq'
  end

  match '*a', to: 'errors#routing', via: :all
end

Dir[Rails.root.join("templates/front/*/routes.rb")].each do |f|
  require f
end