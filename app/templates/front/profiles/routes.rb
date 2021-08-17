Rails.application.routes.draw do
  scope module: 'profiles' do
    resource :profiles, controller: 'main'
  end
end