# encoding: utf-8
Rails.application.routes.draw do
  scope module: 'pre_assignments' do
    resources :pre_assignment_delivery_errors, only: :index, controller: 'delivery_errors'

    resources :pre_assignment_blocked_duplicates, only: :index, controller: 'blocked_duplicates' do
      post 'update_multiple'
    end

    get '/pre_assignment_ignored', to: 'ignored#index'
    post '/pre_assignment_ignored/update_ignored_pieces', to: 'ignored#update_ignored_pieces'

    # resources :pre_assignment_ignored, only: [:index], controller: 'ignored' do
    #   post 'update_ignored_pieces'
    # end
  end
end