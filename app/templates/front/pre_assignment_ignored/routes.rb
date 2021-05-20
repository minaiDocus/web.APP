Rails.application.routes.draw do
  namespace :pre_assignment_ignored do
  	get '/',  to: 'main#index', as: 'index'
  	post 'update_ignored_pieces',  to: 'main#update_ignored_pieces', as: 'update_ignored_pieces'
  end
end