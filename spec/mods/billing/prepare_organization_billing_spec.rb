# -*- encoding : UTF-8 -*-
require 'spec_helper'

describe BillingMod::V1::PrepareOrganizationBilling do
  def create_users(number=1, _package='ido_classic')
    organization = Organization.first

    number.times do |i|
      _user = { email: "user1#{i}@idocus.com", password: '123456', code: "TST%A1#{i}", first_name: "f_name1#{i}", last_name: "l_name1#{i}", phone_number: "123", company: "Organization" }

      user = User.new(_user)
      user.organization = organization

      user.build_options if user.options.nil?

      if _package == 'ido_classic'
        package = BillingMod::V1::Package.create(period: CustomUtils.period_of(Time.now), user: user, name: 'ido_classic', upload_active: true, bank_active: true, scan_active: true, mail_active: true, preassignment_active: false)
      else
        package = BillingMod::V1::Package.create(period: CustomUtils.period_of(Time.now), user: user, name: 'ido_micro_plus', upload_active: true, bank_active: false, scan_active: true, mail_active: true, preassignment_active: true)
      end

      package.save
      user.save

      user.account_book_types.create(name: "AC", description: "AC (Achats)", position: 1, entry_type: 2, currency: "EUR", domain: "AC - Achats", account_number: "0ACC", charge_account: "471000", vat_accounts: {'20':'445660', '8.5':'153141', '13':'754213'}.to_json, anomaly_account: "471000", is_default: true, is_expense_categories_editable: true, organization_id: organization.id)
    end
  end

  def create_extra_order(organization)
    BillingMod::V1::ExtraOrder.create(
      created_at: "2020-03-01 21:00:00", updated_at: "2020-03-01 21:00:00",
      name: 'Test extra order', owner: organization, price: -300, period: CustomUtils.period_of(Time.now)
    )
  end

  before(:all) do
    Timecop.freeze(Time.local(2020,03,15))
    DatabaseCleaner.start

    organization = create :organization, code: "TST"
  end

  after(:all) do
    Timecop.return
    DatabaseCleaner.clean
  end

  before(:each) do
    User.destroy_all
    BillingMod::V1::Billing.destroy_all
  end

  # it 'has normal customers size from the current period' do
  #   organization = Organization.first

  #   customers.size = 
  # end

  it 'creates normal extra order billings', :extra_order do
    period        = CustomUtils.period_of(Time.now)
    organization  = Organization.first

    create_extra_order(organization)

    BillingMod::V1::PrepareOrganizationBilling.new(organization, period).execute

    billings = organization.reload.billings

    expect(billings.collect(&:name)).to include('extra_order')

    extra = billings.where(kind: 'extra')

    expect(extra.size).to eq 1
    expect(extra.first.price).to eq -30000
  end

  context 'discount billings', :discount do
    it 'creates no billing with default params ' do
      period       = CustomUtils.period_of(Time.now)
      organization = Organization.first

      BillingMod::V1::PrepareOrganizationBilling.new(organization, period).execute

      billings = organization.billings.of_period(period)

      expect(billings.size).to eq 0
      expect(organization.total_billing_of(period)).to eq 0
    end

    it 'creates positive classic and retriever discount' do
      period       = CustomUtils.period_of(Time.now)
      organization = Organization.first

      create_users(155)

      BillingMod::V1::PrepareOrganizationBilling.new(organization, period).execute

      billings = organization.billings.of_period(period)

      classic_discount_price   = (155 * -1.5)
      retriever_discount_price = (155 * -0.5)

      classic_billing   = billings.where(name: 'classic_discount').first
      retriever_billing = billings.where(name: 'retriever_discount').first

      expect(billings.size).to eq 2
      expect(classic_billing.price).to eq classic_discount_price * 100
      expect(retriever_billing.price).to eq retriever_discount_price * 100
      
      expect(organization.total_billing_of(period)).to eq (classic_discount_price + retriever_discount_price) * 100
    end
  end

  context 'excess billings', :excess do
    it 'creates mutualized ido classique excess' do
      period       = CustomUtils.period_of(Time.now)
      organization = Organization.first

      create_users(2)

      User.all.each do |user|
        data_flow               = user.current_flow
        data_flow.compta_pieces = 150

        data_flow.save
      end

      BillingMod::V1::PrepareOrganizationBilling.new(organization, period).execute

      billings = organization.billings.of_period(period)

      excess_billing = billings.where(name: 'ido_classic_excess').first
      data_excess    = excess_billing.associated_hash

      expect(data_excess[:excess]).to eq 100
      expect(excess_billing.price).to eq (0.25 * 100) * 100
    end

    it 'creates mutualized ido nano excess' do
      period       = CustomUtils.period_of(Time.now)
      organization = Organization.first

      create_users(2, 'ido_micro_plus')

      User.all.each do |user|
        data_flow               = user.current_flow
        data_flow.compta_pieces = 150

        data_flow.save
      end

      BillingMod::V1::PrepareOrganizationBilling.new(organization, period).execute

      billings = organization.billings.of_period(period)

      excess_billing = billings.where(name: 'ido_micro_plus_excess').first
      data_excess    = excess_billing.associated_hash

      expect(data_excess[:excess]).to eq 250
      expect(excess_billing.price).to eq (0.3 * 250) * 100
    end
  end
end