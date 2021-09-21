# encoding: utf-8
Rails.application.routes.draw do
  scope module: 'dashboard' do
    get 'test/abc', to: 'main#test', as: 'main_test'
    post 'test/abc', to: 'main#test', as: 'post_main_test'

    resources :dashboard, only: :index, controller: 'main' do
      collection do
        post :choose_default_summary
        get :last_scans
        get :last_uploads
        get :last_dematbox_scans
        get :last_retrieved
        post :add_customer_to_favorite
      end
    end
  end
end
