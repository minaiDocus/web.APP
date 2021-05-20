Rails.application.routes.draw do
  scope module: 'profiles' do
    resource :profile, controller: 'main'
  end
end