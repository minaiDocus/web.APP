# -*- encoding : UTF-8 -*-
require 'spec_helper'

describe Billing::PrepareUserBilling do
  def create_operation(user)
    operation = Operation.create(
      created_at: "2020-03-01 21:00:00", updated_at: "2020-03-01 21:00:00",
      date: "2020-02-02", value_date: "2020-02-02", transaction_date: "2020-02-02", label: "SARL 231E47", amount: 500.0,
      category: "Autres recettes", processed_at: "2020-02-02 04:30:51",
      is_locked: false, organization_id: user.organization.id, user_id: user.id, bank_account_id: 1,
      api_id: "456654546", api_name: "capidocus",
      is_coming: false, deleted_at: nil, forced_processing_at: nil, forced_processing_by_user_id: nil, currency: {}
    )
  end

  def create_paper_processes(user)
    operation = PaperProcess.create(
      created_at: "2020-03-01 21:00:00", updated_at: "2020-03-01 21:00:00",
      type: 'scan', tracking_number: '001', customer_code: user.code, pack_name: "#{user.code} AC 202003", user_id: user.id
    )
  end

  before(:all) do
    Timecop.freeze(Time.local(2020,03,15))
    DatabaseCleaner.start

    2.times do |i|
      organization = create :organization, code: "TS#{i}"
      Address.create(first_name: 'Test', last_name: 'Test', company: "TS#{i}", address_1: 'abc rue abc', city: 'Paris', zip: 75113, country: 'France', is_for_billing: true, locatable_type: 'Organization', locatable_id: organization.id)

      users = [
                { email: "user1#{i}@idocus.com", password: '123456', code: "TS#{i}%A1#{i}", first_name: "f_name1#{i}", last_name: "l_name1#{i}", phone_number: "123", company: "Organization" },
                { email: "user2#{i}@idocus.com", password: '123456', code: "TS#{i}%B2#{i}", first_name: "f_name2#{i}", last_name: "l_name2#{i}", phone_number: "123", company: "Organization" }
              ]

      users.each do |_user|
        user = User.new(_user)
        user.organization = organization

        user.build_options if user.options.nil?
        package = Management::Package.create(period: CustomUtils.period_of(Time.now), user: user, name: 'ido_classic', upload_active: true, bank_active: true, scan_active: true, mail_active: true, preassignment_active: false)

        package.save
        user.save

        user.account_book_types.create(name: "AC", description: "AC (Achats)", position: 1, entry_type: 2, currency: "EUR", domain: "AC - Achats", account_number: "0ACC", charge_account: "471000", vat_accounts: {'20':'445660', '8.5':'153141', '13':'754213'}.to_json, anomaly_account: "471000", is_default: true, is_expense_categories_editable: true, organization_id: organization.id)
        # Subscription.create(period_duration: 1, current_packages: '["ido_classique", "pre_assignment_option"]', number_of_journals: 5, organization_id: nil, user_id: user.id)
      end
    end

    # Timecop.freeze(Time.local(2020,04,15)) #Jump in time to next month
  end

  after(:all) do
    Timecop.return
    DatabaseCleaner.clean
  end

  before(:each) do
    Finance::Billing.destroy_all
    Invoice.destroy_all
    Operation.destroy_all
  end

  it 'create basic package', :basic_package do
    user = User.last
    
    package = user.current_package

    expect(package.name).to eq 'ido_classic'
    expect(package.period).to eq CustomUtils.period_of(Time.now)
    expect(package.base_price).to eq 20
    expect(package.excess_price).to eq 0.25
    expect(package.flow_limit).to eq 100
    expect(package.excess_duration).to eq 'month'
  end

  it 'collect data flow', :data_flow do
    user = User.last

    data_flow = user.current_flow

    expect(data_flow.period).to eq CustomUtils.period_of(Time.now)
    expect(data_flow.pieces).to eq 0
    expect(data_flow.operations).to eq 0
    expect(data_flow.all_compta_transactions).to eq 0
  end

  context 'Basic and normal billing', :basic_billing do
    it 'creates classic billing' do
      user = User.last

      Billing::PrepareUserBilling.new(user, CustomUtils.period_of(Time.now)).execute

      billings   = user.reload.billings
      first_bill = billings.first

      package    = user.current_package

      expect(billings.size).to be > 0
      expect(first_bill.period).to eq CustomUtils.period_of(Time.now)
      expect(first_bill.name).to eq "ido_classic"
      expect(first_bill.title).to eq package.human_name
      expect(first_bill.price).to eq 20 * 100
    end

    it 'creates valid billings' do
      period = CustomUtils.period_of(Time.now)
      user   = User.last

      Billing::PrepareUserBilling.new(user, period).execute

      billings = user.reload.billings

      expect(billings.size).to eq 4
      expect(billings.collect(&:name)).to include('ido_classic', 'bank_option', 'mail_option', 'preassignment_option')

      discount_bill = billings.where(kind: 'discount').first
      expect(discount_bill.title).to eq 'Remise sur pré-affectation'
      expect(discount_bill.price).to eq -9 * 100

      expect(user.total_billing_of(period)).to eq (35 - 9) * 100
    end
  end

  context 'Flow excess billing', :flow_excess_billing do
    it 'creates compta piece excess billing - month excess' do
      allow(DataProcessor::DataFlow).to receive(:execute).and_return(true)

      period = CustomUtils.period_of(Time.now)
      user = User.last

      data_flow               = user.current_flow
      data_flow.compta_pieces = 200
      data_flow.save

      Billing::PrepareUserBilling.new(user, period).execute

      billings = user.reload.billings

      expect(billings.size).to eq 5
      expect(billings.collect(&:name)).to include('excess_billing')

      excess_bill = billings.where(kind: 'excess').first

      excess_price = 100 * 0.25
      expect(excess_bill.price).to eq excess_price * 100
      expect(user.total_billing_of(period)).to eq ((35 - 9) + excess_price) * 100
    end

    it 'creates compta piece excess billing - annual excess' do
      allow(DataProcessor::DataFlow).to receive(:execute).and_return(true)

      period      = CustomUtils.period_of(Time.now)
      prev_period = CustomUtils.period_of(1.month.ago)

      user = User.last

      package      = user.current_package
      package.update(name: 'ido_micro', upload_active: true, preassignment_active: true, bank_active: true, mail_active: false, scan_active: true)

      prev_package = package.dup
      prev_package.period = prev_period
      prev_package.save

      prev_flow               = user.flow_of(prev_period)
      prev_flow.compta_pieces = 20
      prev_flow.save

      data_flow               = user.current_flow
      data_flow.compta_pieces = 200
      data_flow.save

      Billing::PrepareUserBilling.new(user, period).execute

      billings = user.reload.billings

      expect(billings.size).to eq 2
      expect(billings.collect(&:name)).to include('ido_micro', 'excess_billing')

      excess_bill = billings.where(kind: 'excess').first

      excess_price = 120 * 0.25
      expect(excess_bill.price).to eq excess_price * 100
      expect(user.total_billing_of(period)).to eq (10 + excess_price) * 100
    end

    it '[PENDING] - creates compta piece excess billing - annual excess - (a previous excess_billing exist)' do
      allow(DataProcessor::DataFlow).to receive(:execute).and_return(true)

      period      = CustomUtils.period_of(Time.now)
      prev_period = CustomUtils.period_of(1.month.ago)

      user = User.last

      package      = user.current_package
      package.update(name: 'ido_micro', upload_active: true, preassignment_active: true, bank_active: true, mail_active: false, scan_active: true)

      prev_package        = package.dup
      prev_package.period = prev_period
      prev_package.save

      prev_flow               = user.flow_of(prev_period)
      prev_flow.compta_pieces = 200
      prev_flow.save

      data_flow               = user.current_flow
      data_flow.compta_pieces = 200
      data_flow.save

      Billing::PrepareUserBilling.new(user, prev_period).execute
      Billing::PrepareUserBilling.new(user, period).execute

      billings = user.reload.billings

      expect(billings.size).to eq 4
      expect(billings.collect(&:name)).to include('ido_micro', 'excess_billing')

      excess_bill = billings.of_period(period).where(kind: 'excess').last

      excess_price = 100 * 0.25
      expect(excess_bill.price).to eq excess_price * 100
      expect(user.total_billing_of(period)).to eq (10 + excess_price) * 100
    end
  end

  context 'Service excess billing', :service_excess_billing do
    it 'creates valid bank and journal excess' do
      allow(DataProcessor::DataFlow).to receive(:execute).and_return(true)

      period = CustomUtils.period_of(Time.now)

      user = User.last

      data_flow                = user.current_flow
      data_flow.bank_excess    = 5
      data_flow.journal_excess = 5
      data_flow.save

      Billing::PrepareUserBilling.new(user, period).execute

      billings = user.reload.billings

      expect(billings.collect(&:name)).to include('bank_excess', 'journal_excess')

      bank_excess_bill    = billings.where(name: 'bank_excess').first
      journal_excess_bill = billings.where(name: 'journal_excess').first

      expect(bank_excess_bill.price).to eq (5 * 2) * 100
      expect(journal_excess_bill.price).to eq (5 * 1) * 100
    end

    it 'creates previous operation billing' do
      period = CustomUtils.period_of(Time.now)

      user = User.last

      package      = user.current_package
      package.update(name: 'ido_retriever', upload_active: false, preassignment_active: true, bank_active: true, mail_active: false, scan_active: false)

      create_operation(user)

      Billing::PrepareUserBilling.new(user, period).execute

      billings = user.reload.billings

      expect(billings.size).to eq 2
      expect(billings.collect(&:name)).to include('ido_retriever', 'operations_billing')

      operation_billing = billings.where(name: 'operations_billing').first

      expect(operation_billing.price).to eq 5 * 100
      expect(user.total_billing_of(period)).to eq 10 * 100
    end

    it 'creates digitize package billing' do
      allow(DataProcessor::DataFlow).to receive(:execute).and_return(true)

      period = CustomUtils.period_of(Time.now)

      user = User.last

      create_paper_processes(user)
      package = user.current_package
      package.update(name: 'ido_digitize', upload_active: false, preassignment_active: true, bank_active: false, mail_active: false, scan_active: false)

      data_flow                = user.current_flow
      data_flow.scanned_sheets = 5
      data_flow.save

      Billing::PrepareUserBilling.new(user, period).execute

      billings = user.reload.billings

      expect(billings.collect(&:name)).to include('ido_digitize', 'scanned_sheets', 'paper_processes')

      digitize            = billings.where(name: 'ido_digitize').first
      scanned_sheets_bill = billings.where(name: 'scanned_sheets').first
      paper_processes_bill = billings.where(name: 'paper_processes').first

      scanned_sheets_price  = 5 * 0.1
      paper_processes_price = 1 * 1

      expect(digitize.price).to eq 0
      expect(scanned_sheets_bill.price).to eq scanned_sheets_price * 100
      expect(paper_processes_bill.price).to eq paper_processes_price * 100

      expect(user.total_billing_of(period)).to eq (scanned_sheets_price + paper_processes_price) * 100
    end
  end
end