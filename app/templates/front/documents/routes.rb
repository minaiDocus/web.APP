# encoding: utf-8
Rails.application.routes.draw do
  namespace :documents do
    get '/', to: "main#index", as: "document_main_index"
  end
end