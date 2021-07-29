Rails.application.routes.draw do
  scope module: 'addresses' do
    resources :addresses, controller: 'main'
  end
end