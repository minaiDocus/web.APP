Rails.application.routes.draw do
  scope module: 'orders' do
    resources :organizations, only: [] do
      resources :customers, only: [] do
      	resources :orders, except: %w(index show), controller: 'main'
      end
    end
  end
end