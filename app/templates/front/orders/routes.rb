Rails.application.routes.draw do
  scope module: 'orders' do
    resources :orders, except: %w(index show), controller: 'main'
  end
end