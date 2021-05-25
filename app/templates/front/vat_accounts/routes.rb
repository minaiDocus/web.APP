Rails.application.routes.draw do
  scope module: 'vat_accounts' do
	 	resources :vat_accounts, controller: 'main' do
      get   'edit_multiple',   on: :collection
      patch 'update_multiple', on: :collection
    end
  end
end