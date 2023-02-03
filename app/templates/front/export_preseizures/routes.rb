# encoding: utf-8
Rails.application.routes.draw do
  scope module: 'export_preseizures' do

    get 'list_export_preseizures', to: 'main#index', as: 'export_preseizures_list'
  
  end

end