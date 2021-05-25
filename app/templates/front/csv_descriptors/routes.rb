Rails.application.routes.draw do
  scope module: 'csv_descriptors' do
	 	resource :csv_descriptor, controller: 'main' do
      patch 'activate',   on: :member
      patch 'deactivate', on: :member
    end

    resource :use_csv_descriptor, only: %w(edit update), controller: 'use'
  end
end