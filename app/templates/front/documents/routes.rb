# encoding: utf-8
Rails.application.routes.draw do
  namespace :documents do
    get '/contents/original/*all', to: 'main#handle_bad_url', as: 'handle_bad_url'

	  # get '/account' => redirect('/documents') # TODO ...
	  get '/:id/download/:style',            to: 'main#download', as: 'download'
	  get '/processing/:id/download(/:style)', to: 'main#download_processing', as: 'download_processing'
	  get '/pieces/:id/download(/:style)',   to: 'main#piece', as: 'piece'
	  get '/pieces/download_selected/:pieces_ids(/:style)', to: 'main#download_selected', as: 'download_selected'
	  get '/temp_documents/:id/download(/:style)',   to: 'main#temp_document', as: 'temp_document'
	  get '/pack/:id/download',              to: 'main#pack', as: 'pack'
	  get '/multi_pack_download',            to: 'main#multi_pack_download', as: 'multi_pack_download'
	  post '/select_to_export',              to: 'main#select_to_export', as: 'select_to_export'
	  get '/export_preseizures/:params64',   to: 'main#export_preseizures', as: 'export_preseizures'
	  get '/preseizure_account/:id',         to: 'main#preseizure_account', as: 'preseizure_account'

	  get '/preseizure/:id/edit',            to: 'main#edit_preseizure', as: 'edit_preseizure'
	  post '/preseizure/:id/update',         to: 'main#update_preseizure', as: 'update_preseizure'
	  get '/preseizure/account/:id/edit',    to: 'main#edit_preseizure_account', as: 'edit_preseizure_account'
	  post '/preseizure/account/:id/update', to: 'main#update_preseizure_account', as: 'update_preseizure_account'
	  get '/preseizure/entry/:id/edit',      to: 'main#edit_preseizure_entry', as: 'edit_preseizure_entry'
	  post '/preseizure/entry/:id/update',   to: 'main#update_preseizure_entry', as: 'update_preseizure_entry'
	  post '/deliver_preseizures',           to: 'main#deliver_preseizures', as: 'deliver_preseizures'
	  post '/update_multiple_preseizures',   to: 'main#update_multiple_preseizures', as: 'update_multiple_preseizures'
	  post '/already_exist_document',        to: 'main#already_exist_document', as: 'already_exist_document'
	  get '/exist_document/:id/download',    to: 'main#exist_document', as: 'exist_document'

	  resources :documents, path: '', controller: 'main' do
      get  'packs',                           on: :collection
      get  'reports',                         on: :collection
      get  'archive',                         on: :member
      post 'sync_with_external_file_storage', on: :collection
      post 'delete_multiple_piece',           on: :collection
      post 'restore_piece',                   on: :collection
    end

    resource :tags, controller: 'tags' do
      post 'update_multiple', on: :collection
      post 'get_tag_content', on: :collection
    end
    resource :compta_analytics, controller: 'compta_analytics' do
      post 'update_multiple', on: :collection
    end
    resource :upload, controller: 'uploads'
  end
end