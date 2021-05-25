Rails.application.routes.draw do
  scope module: 'collaborators' do
    resources :collaborators, controller: 'main' do
      member do
        post   :add_to_organization
        delete :remove_from_organization
      end

      resource :rights, only: %w(edit update), module: 'rights', controller: 'main'
      resource :file_storage_authorizations, only: %w(edit update), module: 'file_storage_authorizations', controller: 'main'
    end

    resources :guest_collaborators, controller: 'guest' do
      get 'search', on: :collection
    end
  end
end