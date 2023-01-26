# -*- encoding : UTF-8 -*-
class SoftwareMod::Export::Ciel
  def initialize(preseizures, tmp_dir=nil, _format='txt')
    @preseizures = preseizures
    @user        = preseizures.first.user
    @dir         = tmp_dir.presence || CustomUtils.mktmpdir('ciel')

    @format      = _format
  end

  def execute
    return 'not_authorized' if not @user.uses?(:ciel)

    @base_name = @preseizures.first.report.name.tr(' ', '_').tr('%', '_')
    @file_path = "#{@dir}/#{@base_name}.txt"

    File.open(@file_path, 'w'){ |file| file.write(datas) }

    @file_path
  end

  private

  def datas
    data = []

    if @preseizures.any?
      ### HEADERS ####
        data << "##Transfert"
        data << "##Section\tDos"
        data << "EUR"
        data << "##Section\tMvt"
      ### HEADERS ####

      accounting_plan = @preseizures.first.user.accounting_plan

      @preseizures.each_with_index do |preseizure, index|
        user          = preseizure.user
        journal_name  = preseizure.report.journal({name_only: false}).try(:name) || preseizure.journal_name
        piece         = preseizure.piece

        preseizure.accounts.each do |account|
          entry   = account.entries.first

          label   = preseizure.piece_number
          label   = preseizure.operation_label[0..34].gsub("\t", ' ') if preseizure.operation_label.present?

          line = []

          third_party_name   = accounting_plan.customers.where(third_party_account: account.number).first.try(:third_party_name)
          third_party_name ||= accounting_plan.providers.where(third_party_account: account.number).first.try(:third_party_name)

          line << "\"#{index.to_s[0..4]}\""
          line << "\"#{journal_name.to_s[0..1]}\""
          line << "\"#{preseizure.date.strftime('%d/%m/%Y')}\""
          line << "\"#{account.number.to_s[0..5]}\""
          line << "\"#{third_party_name.to_s[0..10]}\""
          line << "\"#{entry.amount.to_s[0..12]}\""
          line << "#{entry.debit? ? 'D' : 'C'}"
          line << "B"
          line << "\"#{preseizure.third_party.to_s[0..10]}\""
          line << "\"#{label.to_s[0..11]}\""
          line << "\"10\""

          data << line.join("\t")
        end
      end
    end

    data.join("\n")
  end
end
