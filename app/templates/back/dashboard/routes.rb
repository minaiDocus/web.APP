# encoding: utf-8
Rails.application.routes.draw do
  namespace :admin do
    namespace :dashboard do
      get '/', to: "main#index", as: "dashboard_main_index"
      get '/ocr_needed_temp_packs', to: "main#ocr_needed_temp_packs", as: "ocr_needed_temp_packs_admin"
    end
  end
end
