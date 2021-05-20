Rails.application.routes.draw do
  namespace :pre_assignment_blocked_duplicates do
  	get '/',  to: 'main#index', as: 'index'
  	post 'update_multiple',  to: 'main#update_multiple', as: 'update_multiple'
  end
end