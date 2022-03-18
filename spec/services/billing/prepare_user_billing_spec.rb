# -*- encoding : UTF-8 -*-
require 'spec_helper'

describe Billing::PrepareUserBilling do
  def create_bank_account_with_operation(user, i=8, month=2)
    bank_account = BankAccount.create(
      created_at: "2020-03-01 21:00:00", updated_at: "2020-03-01 21:00:00",
      bank_name: "Allianz-#{i}", name: "Allianz-#{i}", number: "456654546#{i}",
      user: user, api_id: "456654546#{i}", api_name: 'capidocus', journal: 'BQ', currency: 'EUR',
      original_currency: {"id"=>"EUR", "symbol"=>"€", "prefix"=>false, "precision"=>2, "marketcap"=>nil, "datetime"=>nil, "name"=>"Euro"},
      is_used: true, accounting_number: "512000", temporary_account: '471000',
      start_date: '2020-03-02', type_name: "unknown-#{i}", lock_old_operation: true, permitted_late_days: 12
    )

    operation = Operation.create(
      created_at: "2020-03-01 21:00:00", updated_at: "2020-03-01 21:00:00",
      date: "2020-0#{month}-02", value_date: "2020-0#{month}-02", transaction_date: "2020-0#{month}-02", label: "SARL 231E47", amount: 500.0,
      category: "Autres recettes", processed_at: "2020-0#{month}-02 04:30:51",
      is_locked: false, organization_id: user.organization.id, user_id: user.id, bank_account_id: bank_account.id,
      api_id: "456654546#{i}", api_name: "capidocus",
      is_coming: false, deleted_at: nil, forced_processing_at: nil, forced_processing_by_user_id: nil, currency: {}
    )
  end

  before(:all) do
    Timecop.freeze(Time.local(2020,03,15))
    DatabaseCleaner.start

    2.times do |i|
      organization = create :organization, code: "TS#{i}"
      Subscription.create(period_duration: 1, tva_ratio: 1.2, user_id: nil, organization_id: organization.id)
      Address.create(first_name: 'Test', last_name: 'Test', company: "TS#{i}", address_1: 'abc rue abc', city: 'Paris', zip: 75113, country: 'France', is_for_billing: true, locatable_type: 'Organization', locatable_id: organization.id)
      organization.subscription.find_or_create_period(Date.today)

      users = [
                { email: "user1#{i}@idocus.com", password: '123456', code: "TS#{i}%A1#{i}", first_name: "f_name1#{i}", last_name: "l_name1#{i}", phone_number: "123", company: "Organization" },
                { email: "user2#{i}@idocus.com", password: '123456', code: "TS#{i}%B2#{i}", first_name: "f_name2#{i}", last_name: "l_name2#{i}", phone_number: "123", company: "Organization" }
              ]

      users.each do |_user|
        user = User.new(_user)
        user.organization = organization

        user.build_options if user.options.nil?
        package = Management::Package.create(period: CustomUtils.period_of(Time.now), user: user, name: 'ido_classic', upload_active: true, bank_active: true, scan_active: true, mail_active: true)

        user.save

        user.account_book_types.create(name: "AC", description: "AC (Achats)", position: 1, entry_type: 2, currency: "EUR", domain: "AC - Achats", account_number: "0ACC", charge_account: "471000", vat_accounts: {'20':'445660', '8.5':'153141', '13':'754213'}.to_json, anomaly_account: "471000", is_default: true, is_expense_categories_editable: true, organization_id: organization.id)
        Subscription.create(period_duration: 1, current_packages: '["ido_classique", "pre_assignment_option"]', number_of_journals: 5, organization_id: nil, user_id: user.id)
      end
    end

    Timecop.freeze(Time.local(2020,04,15)) #Jump in time to next month
  end

  after(:all) do
    Timecop.return
    DatabaseCleaner.clean
  end

  before(:each) do
    Invoice.destroy_all
    Operation.destroy_all
  end

  it 'create basic package', :basic_package do
    user = User.last
    
    package = user.current_package

    expect(package.name).to eq 'ido_classic'
    expect(package.period).to eq CustomUtils.period_of(Time.now)
  end

  it 'collect data flow', :data_flow do
    user = User.last

    data_flow = user.current_flow

    expect(data_flow.period).to eq CustomUtils.period_of(Time.now)
  end
end