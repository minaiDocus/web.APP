Rails.application.routes.draw do
  scope module: 'retrievers' do
    resources :retrievers, controller: 'main' do
      get 'new_internal', on: :collection
      get 'edit_internal', on: :collection
      get   'list',                     on: :collection
      post 'export_connector_to_xls',   on: :collection
      get  'get_connector_xls(/:key)', action: 'get_connector_xls',   on: :collection
    end
  end
end