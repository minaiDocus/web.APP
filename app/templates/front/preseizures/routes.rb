Rails.application.routes.draw do
  scope module: 'preseizures' do
  	resources :preseizure_accounts, only: [], controller: 'accounts' do
  		post 'accounts_list'
  	end

	  resources :preseizures, only: %w(index update), controller: 'main' do
      post 'deliver', on: :member
    end
  end
end