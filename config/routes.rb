require 'sidekiq/web'
require 'sidekiq-scheduler/web'

class ActionDispatch::Routing::Mapper
  def draw(template)
    instance_eval(File.read(Rails.root.join("app/templates/front/#{template}/routes.rb")))
  end
end

Rails.application.routes.draw do
  draw('dashboard')
  draw('organizations')
  draw('documents')

  mount Ckeditor::Engine => '/ckeditor'

  root to: 'front/index#index'
  get '/front/notifications/', controller: 'front/index', action: 'notifications'

  wash_out :dematbox

  devise_for :users

  authenticate :user, lambda { |u| u.is_admin } do
    mount Sidekiq::Web => '/sidekiq'
  end

  match '*a', to: 'errors#routing', via: :all
end

