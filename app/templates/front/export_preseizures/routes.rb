# encoding: utf-8
Rails.application.routes.draw do
  scope module: 'export_preseizures' do

    get 'list_export_preseizures', to: 'main#index', as: 'export_preseizures_list'
    get 'download_export_preseizures/:q', to: 'main#download_export_preseizures', as: 'download_export_preseizures'

  end

end