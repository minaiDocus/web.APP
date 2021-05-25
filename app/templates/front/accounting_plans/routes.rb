Rails.application.routes.draw do
  scope module: 'accounting_plans' do
	 	resource :accounting_plan, except: %w(new create destroy), controller: 'main' do
      member do
        patch  :import
        post   :auto_update
        post   :ibiza_synchronize
        patch  :import_fec
        get    :import_model
        get    :import_fec_processing
        delete :destroy_providers
        delete :destroy_customers
      end

      resources :vat_accounts, module: 'vat_accounts', controller: 'main' do
        get   'edit_multiple',   on: :collection
        patch 'update_multiple', on: :collection
      end
    end
  end
end