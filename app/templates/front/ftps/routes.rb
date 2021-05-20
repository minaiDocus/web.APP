Rails.application.routes.draw do
  scope module: 'ftps' do
    resource :ftp, only: %w(edit update destroy), controller: 'main'
  end
end