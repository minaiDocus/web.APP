Rails.application.routes.draw do
  scope module: 'accounting_plans' do
    resources :organizations, only: [] do
      resources :customers, only: [] do
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
        end
      end
    end
  end
end