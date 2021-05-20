Rails.application.routes.draw do
  scope module: 'group_organizations' do
	resources :group_organizations, controller: 'main'
  end
end