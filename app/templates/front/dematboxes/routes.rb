Rails.application.routes.draw do
  scope module: 'dematboxes' do
    resource :dematbox, only: %w(create destroy), controller: 'main'
  end
end