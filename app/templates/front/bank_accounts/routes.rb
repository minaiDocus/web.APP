Rails.application.routes.draw do
  namespace :bank_accounts do
    get '/', to: 'main#index', as: 'index'
  end
end