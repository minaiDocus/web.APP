Rails.application.routes.draw do
  namespace :preseizure_accounts do
  	post '/accounts_list',       to: 'main#accounts_list', as: 'accounts_list'
  end
end