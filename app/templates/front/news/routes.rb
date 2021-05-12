# encoding: utf-8
Rails.application.routes.draw do
  namespace :news do
    get '/', to: "main#index", as: "main_index"
  end
end