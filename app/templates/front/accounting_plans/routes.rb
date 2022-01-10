Rails.application.routes.draw do
  scope module: 'accounting_plans' do
    resources :organizations, only: [] do
      resources :customers, only: [] do
        resource :accounting_plan, controller: 'main' do
          member do
            patch  :import
            post   :auto_update
            post   :ibiza_synchronize
            post   :insert_general_account
            patch  :import_fec
            get    :import_model
            get    :import_fec_processing
            delete :destroy_providers
            delete :destroy_customers
          end
        end
      end
    end
  end
end