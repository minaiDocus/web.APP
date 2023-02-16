# -*- encoding : UTF-8 -*-
require 'spec_helper'

describe SoftwareMod::Export::Preseizures do
  def all_softwares
    ['cegid', 'ciel', 'coala', 'cogilog', 'fec_acd', 'fec_agiris', 'quadratus']
  end

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
    @piece        = FactoryBot.create :piece, pack: pack, user: @user, organization: @organization, name: (@report.name + ' 001'), position: 1
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
    it 'generate normal file', :generation do
      allow_any_softwares

      all_softwares.each do |software_name|
        p "=== #{software_name} ==="
        p result = SoftwareMod::Export::Preseizures.new(software_name).execute(@preseizures, false, 0, @user.id)

        export = PreAssignmentExport.where(for: software_name).last

        expect(result.present?).to be true
        expect(File.exist?(result.to_s)).to be true

        expect(export.present?).to be true
        expect(export.state).to eq 'generated'
        expect(File.exist?(export.cloud_content_object.reload.path)).to be true
        expect(export.preseizures.collect(&:id)).to eq Array(@preseizures).collect(&:id)
      end
    end

    it 'generate normal coala xls with piece file', :zip do
      allow_any_softwares

      p result = SoftwareMod::Export::Preseizures.new('coala', 'xls').execute(@preseizures, true, 0, @user.id)

      export = PreAssignmentExport.where(for: 'coala').last

      dir        = File.dirname(result)
      piece_name = File.basename(@piece.cloud_content_object.reload.path)
      piece_path = "#{dir}/#{piece_name}"

      expect(result.present?).to be true
      expect(File.exist?(result.to_s)).to be true
      expect(result.to_s.split('.')[1]).to eq 'zip'

      expect(export.present?).to be true
      expect(export.state).to eq 'generated'
      expect(File.exist?(export.cloud_content_object.reload.path)).to be true
      expect(export.preseizures.collect(&:id)).to eq Array(@preseizures).collect(&:id)

      expect(File.exist?(piece_path)).to be true
    end

    it 'generate normal cegid tra with piece file' do
      allow_any_softwares

      p result = SoftwareMod::Export::Preseizures.new('cegid', 'tra').execute(@preseizures, true)

      dir        = File.dirname(result)
      piece_name = SoftwareMod::Export::Cegid.file_name_format(@piece)
      piece_path = "#{dir}/#{piece_name}"

      expect(result.present?).to be true
      expect(File.exist?(result.to_s)).to be true
      expect(result.to_s.split('.')[1]).to eq 'zip'

      expect(File.exist?(piece_path)).to be true
    end

    it 'generate normal quadratus txt with piece file' do
      allow_any_softwares

      p result = SoftwareMod::Export::Preseizures.new('quadratus').execute(@preseizures, true)

      dir        = File.dirname(result)
      piece_name = SoftwareMod::Export::Quadratus.file_name_format(@piece)
      piece_path = "#{dir}/#{piece_name}"

      expect(result.present?).to be true
      expect(File.exist?(result.to_s)).to be true
      expect(result.to_s.split('.')[1]).to eq 'zip'

      expect(File.exist?(piece_path)).to be true
    end
  end
end