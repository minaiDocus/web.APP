Rails.application.routes.draw do
  namespace :group_organizations do
	resources :group_organizations, path: '', as: ''
  end
end