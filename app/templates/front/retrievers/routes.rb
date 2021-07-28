Rails.application.routes.draw do
  resources :retrievers, module: 'retrievers', controller: 'main' do
    get 'new_internal', on: :collection
    get 'edit_internal', on: :collection
    get  'list',                     on: :collection
    post 'export_connector_to_xls',   on: :collection
    get  'get_connector_xls(/:key)', action: 'get_connector_xls',   on: :collection
  end
end