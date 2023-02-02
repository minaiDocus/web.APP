# -*- encoding : UTF-8 -*-
require 'spec_helper'

describe SoftwareMod::ExportPreseizures do
  def allow_any_softwares
    allow_any_instance_of(Pack::Report::Preseizure).to receive('computed_date').and_return(Time.now)
    allow_any_instance_of(User).to receive('uses?').and_return(true)
  end

  before(:all) do
    DatabaseCleaner.start

    @organization = FactoryBot.create :organization, code: 'IDO'
    @user         = FactoryBot.create :user, code: 'IDO%LEAD', organization_id: @organization.id
    @report       = FactoryBot.create :report, user: @user, organization: @organization
    pack          = FactoryBot.create :pack, owner: @user, organization: @organization , name: (@report.name + ' all')
    @piece        = FactoryBot.create :piece, pack: pack, user: @user, organization: @organization, name: (@report.name + ' 001')
    @journal      = FactoryBot.create :account_book_type, :journal_with_preassignment, name: 'AC', description: 'Achat', user: @user
    @accounting_plan = AccountingPlan.create(user_id: @user.id)

    @piece.cloud_content_object.attach(File.open("#{Rails.root}/spec/support/files/2019090001.pdf"), '2019090001.pdf')
    @piece.save
    @preseizures  = FactoryBot.create :preseizure, user: @user, organization: @organization, report_id: @report.id, piece: @piece, third_party: 'Google', piece_number: 'G001', date: Time.now, cached_amount: 10.0

    accounts  = Pack::Report::Preseizure::Account.create([
      { type: 1, number: '601109', preseizure_id: @preseizures.id },
      { type: 2, number: '471000', preseizure_id: @preseizures.id },
      { type: 3, number: '471001', preseizure_id: @preseizures.id },
    ])
    entries  = Pack::Report::Preseizure::Entry.create([
      { type: 1, number: '1', amount: 1213.48, preseizure_id: @preseizures.id, account_id: accounts[0].id },
      { type: 2, number: '1', amount: 1011.23, preseizure_id: @preseizures.id, account_id: accounts[1].id },
      { type: 2, number: '1', amount: 202.25, preseizure_id: @preseizures.id, account_id: accounts[2].id },
    ])
  end

  context 'generate file path', :generate do
    context 'coala', :coala do
      it 'generate normal coala csv file' do
        allow_any_softwares

        p result = SoftwareMod::ExportPreseizures.new('coala').execute(@preseizures)

        expect(result.present?).to be true
        expect(File.exist?(result.to_s)).to be true
        expect(result.to_s.split('.')[1]).to eq 'csv'
      end

      it 'generate normal coala xls file' do
        allow_any_softwares

        p result = SoftwareMod::ExportPreseizures.new('coala', 'xls').execute(@preseizures)

        expect(result.present?).to be true
        expect(File.exist?(result.to_s)).to be true
        expect(result.to_s.split('.')[1]).to eq 'xls'
      end

      it 'generate normal coala xls with piece file', :zip do
        allow_any_softwares

        p result = SoftwareMod::ExportPreseizures.new('coala', 'xls').execute(@preseizures, true)

        expect(result.present?).to be true
        expect(File.exist?(result.to_s)).to be true
        expect(result.to_s.split('.')[1]).to eq 'zip'
      end
    end

    context 'cegid', :cegid do
      it 'generate normal cegid csv file' do
        allow_any_softwares

        p result = SoftwareMod::ExportPreseizures.new('cegid').execute(@preseizures)

        expect(result.present?).to be true
        expect(File.exist?(result.to_s)).to be true
        expect(result.to_s.split('.')[1]).to eq 'csv'
      end

      it 'generate normal cegid tra file' do
        allow_any_softwares

        p result = SoftwareMod::ExportPreseizures.new('cegid', 'tra').execute(@preseizures)

        expect(result.present?).to be true
        expect(File.exist?(result.to_s)).to be true
        expect(result.to_s.split('.')[1]).to eq 'tra'
      end

      it 'generate normal cegid tra with piece file' do
        allow_any_softwares

        p result = SoftwareMod::ExportPreseizures.new('cegid', 'tra').execute(@preseizures, true)

        expect(result.present?).to be true
        expect(File.exist?(result.to_s)).to be true
        expect(result.to_s.split('.')[1]).to eq 'zip'
      end
    end

    context 'quadratus', :quadratus do
      it 'generate normal quadratus txt file' do
        allow_any_softwares

        p result = SoftwareMod::ExportPreseizures.new('quadratus').execute(@preseizures)

        expect(result.present?).to be true
        expect(File.exist?(result.to_s)).to be true
        expect(result.to_s.split('.')[1]).to eq 'txt'
      end
    end
  end
end