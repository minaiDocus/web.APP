# encoding: utf-8
Rails.application.routes.draw do
  namespace :organizations do
    get '/', to: "main#index", as: "organization_main_index"
    get '/welcome', to: "main#welcome", as: "organization_main_welcome"
    get '/facture', to: "main#facture", as: "organization_main_facture"
    get '/kits', to: "main#kits", as: "organization_main_kits"
  end
end