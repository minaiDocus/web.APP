Rails.application.routes.draw do
  scope module: 'addresses' do
    post 'addresses/update_all', to: 'main#update_all'
    delete 'addresses/destroy/:id', to: 'main#destroy', as: 'destroy_addresses'

    resources :addresses, controller: 'main'
  end
end