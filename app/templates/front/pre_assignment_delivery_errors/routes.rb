Rails.application.routes.draw do
  namespace :pre_assignment_delivery_errors do
  	get '/',  to: 'main#index', as: 'index'
  end
end