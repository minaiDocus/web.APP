Rails.application.routes.draw do
  scope module: 'analytics' do
    resources :analytics, only: %w(index), controller: 'main'
  end
end