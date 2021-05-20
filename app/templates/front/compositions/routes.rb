Rails.application.routes.draw do
  scope module: 'compositions' do
    resources :compositions, controller: 'main' do
      delete 'reset', on: :collection
    end
  end
end