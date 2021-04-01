# encoding: utf-8
Rails.application.routes.draw do
  namespace :organizations do
    get '/', to: "main#index", as: "organization_main_index"
  end
end