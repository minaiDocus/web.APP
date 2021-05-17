# encoding: utf-8
Rails.application.routes.draw do
  namespace :rights do
    get '/:id/edit', to: 'main#edit', as: 'edit'
	put '/', to: 'main#update', as: 'update'
  end
end