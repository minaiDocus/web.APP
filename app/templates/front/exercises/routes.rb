# encoding: utf-8
Rails.application.routes.draw do
  scope module: 'exercises' do
  	resources :exercises, controller: 'main'
  end
end