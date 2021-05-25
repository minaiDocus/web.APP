Rails.application.routes.draw do
  scope module: 'subscriptions' do
    resource :subscription, controller: 'main'
  end
end