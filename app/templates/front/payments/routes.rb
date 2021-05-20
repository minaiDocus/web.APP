Rails.application.routes.draw do
  scope module: 'payments' do
    resource :payment, controller: 'main' do
      post 'debit_mandate_notify', on: :member
      get  'debit_mandate_notify',  on: :member
      get  'use_debit_mandate',    on: :member
    end
  end
end