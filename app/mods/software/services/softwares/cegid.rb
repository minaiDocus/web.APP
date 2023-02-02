# -*- encoding : UTF-8 -*-
class SoftwareMod::Service::Cegid
  def self.file_name_format(piece)
    piece.name.tr(' ', '_').tr('%', '_') + '.pdf'
  end

  def initialize(preseizures, tmp_dir=nil, _format='csv')
    @preseizures = preseizures
    @user        = preseizures.first.user
    @dir         = tmp_dir.presence || CustomUtils.mktmpdir('cegid')

    @format      = _format
  end

  def execute
    return 'not_authorized' if not @user.uses?(:cegid)

    @base_name = @preseizures.first.report.name.tr(' ', '_').tr('%', '_')
    @file_path = ''

    if @format == 'tra'
      @file_path = to_tra
    else
      @file_path = to_csv
    end

    @file_path
  end

  private

  def to_csv
    file_path = "#{@dir}/#{@base_name}.csv"

    File.open(file_path, 'w') do |f|
      f.write(datas_csv)
    end

    file_path
  end

  def to_tra
    file_path = "#{@dir}/#{@base_name}.tra"

    File.open(file_path, 'w') do |f|
      f.write(datas_tra)
    end

    file_path
  end

  def datas_csv
    lines = []

    @preseizures.each do |preseizure|
      preseizure.entries.by_position.each do |entry|
        lines << format_line(entry)
      end
    end

    lines
  end

  def format_line(entry)
    label = entry.preseizure.operation_name

    if entry.preseizure.piece_id.present?
      journal = entry.preseizure.report.journal({name_only: false})

      general_account = if(entry.account.type == Pack::Report::Preseizure::Account::TVA)
        journal.try(:get_vat_accounts_of, '0')
      elsif(entry.account.type == Pack::Report::Preseizure::Account::TTC)
        journal.try(:account_number)
      else
        journal.try(:charge_account)
      end

      description           = entry.preseizure.organization.ibiza.try(:description).presence || {}
      description_separator = entry.preseizure.organization.ibiza.try(:description_separator).presence || ' - '

      description_name = IbizaLib::Api::Utils.description(entry.preseizure, description, description_separator)
      label = description_name.present? ? description_name : entry.preseizure.third_party
      piece_number = entry.preseizure.piece_number
    else
      operation    = entry.preseizure.operation
      bank_account = operation.try(:bank_account)

      general_account = if(
                            (operation.try(:amount).to_i < 0 && entry.credit?) ||
                            (operation.try(:amount).to_i >= 0 && entry.debit?)
                          )
                          bank_account.try(:accounting_number) || 512_000
                        else
                          bank_account.try(:temporary_account) || 471_000
                        end

      label = entry.preseizure.operation_label[0..34].gsub(';', ',') if entry.preseizure.operation_label.present?
      piece_number = ''
    end

    auxiliary_account = (general_account.to_s != entry.account.number.to_s)? entry.account.number : ''

    if auxiliary_account.present?
      if(entry.preseizure.piece_id.present?)
        is_provider = @user.accounting_plan.providers.where(third_party_account: auxiliary_account).limit(1).size > 0
        is_customer = @user.accounting_plan.customers.where(third_party_account: auxiliary_account).limit(1).size > 0 unless is_provider

        general_account = if is_provider
                            @user.accounting_plan.general_account_providers.presence || 4_010_000_000
                          elsif is_customer
                            @user.accounting_plan.general_account_customers.presence || 4_110_000_000
                          else
                            auxiliary_account
                          end

        auxiliary_account = '' unless is_provider || is_customer
      else
        if general_account != bank_account.try(:accounting_number) && general_account != 512_000
          general_account = if entry.debit?
                              @user.accounting_plan.general_account_providers.presence || 4_010_000_000
                            else
                              @user.accounting_plan.general_account_customers.presence || 4_110_000_000
                            end
        end
      end
    end

    result =  [
                entry.preseizure.computed_date.try(:strftime, "%d%m%Y"),
                entry.preseizure.journal_name.upcase[0..2],
                general_account,
                auxiliary_account,
                entry.debit? ? 'D' : 'C',
                entry.amount,
                label,
                piece_number
              ].join(';')
    return result.to_s
  end

  def datas_tra
    data = []

    line      = ' ' * 222
    line[0]   = '***S5EXPJRLSTD'
    line[33]  = '011'
    line[53]  = 'IDOCUS'
    line[144] = '001'
    line[147]  = '-'
    line[148]  = '-'

    data << line

    @preseizures.each do |preseizure|
      user = preseizure.user

      if preseizure.operation
        label = preseizure.operation_label[0..29]
      else
        label = [preseizure.third_party.presence, preseizure.piece_number.presence].compact.join(' - ')[0..29]
      end

      journal = preseizure.report.journal({ name_only: false })
      nature = case journal.compta_type
               when 'AC'
                if preseizure.entries.where(type: 2).count > 1
                  'AF'
                else
                  'FF'
                end
               when 'VT'
                if preseizure.entries.where(type: 1).count > 1
                  'FC'
                else
                  'AC'
                end
               when 'NDF'
                'OD'
               else
                'BQ'
               end

      preseizure.entries.each do |entry|
        account = case nature
                  when 'AF'
                    if entry.account.type == Pack::Report::Preseizure::Account::TTC
                      user.accounting_plan.general_account_providers.to_s.presence || '401000'
                    else
                      entry.account.try(:number)
                    end
                  when 'FF'
                    if entry.account.type == Pack::Report::Preseizure::Account::TTC
                      user.accounting_plan.general_account_providers.to_s.presence || '401000'
                    else
                      entry.account.try(:number)
                    end
                  when 'AC'
                    if entry.account.type == Pack::Report::Preseizure::Account::TTC
                      user.accounting_plan.general_account_customers.to_s.presence || '411000'
                    else
                      entry.account.try(:number)
                    end
                  when 'FC'
                    if entry.account.type == Pack::Report::Preseizure::Account::TTC
                      user.accounting_plan.general_account_customers.to_s.presence || '411000'
                    else
                      entry.account.try(:number)
                    end
                  else
                    entry.account.try(:number)
                  end


          label = ' ' unless label.present?
          line = ' ' * 222
          line[0] = preseizure.journal_name[0..2]
          line[3..11] = preseizure.computed_date.strftime('%d%m%Y') if preseizure.date
          line[11] = nature
          line[13] = account

          line[30] = 'X' if entry.account.type == Pack::Report::Preseizure::Account::TTC

          account_number = entry.account.try(:number) || ''
          line[31] = account_number if entry.account.type == Pack::Report::Preseizure::Account::TTC

          line[48] = preseizure.piece_number? ? I18n.transliterate(preseizure.piece_number.to_s) : I18n.transliterate(preseizure.third_party.to_s)

          line[83] = I18n.transliterate(label.to_s)

          line[129] = entry.type == 1 ? 'D' : 'C'

          amount = sprintf("%.2f", entry.amount.to_f).to_s.gsub('.', ',')
          window = 150 - amount.size

          line[window..150] = amount

          line[150] = 'N'
          line[151] = preseizure.piece ? preseizure.piece.number.to_s : ' '
          line[172] = 'E--'

          data << line

          file_name = preseizure.piece ? SoftwareMod::Service::Cegid.file_name_format(preseizure.piece) : ' '

          line = ' ' * 222

          if entry.account.type == Pack::Report::Preseizure::Account::TTC
            line[0] = preseizure.journal_name[0..2]
            line[3..11] = preseizure.computed_date.strftime('%d%m%Y') if preseizure.date
            line[11] = nature
            line[13] = case journal.compta_type
                       when 'AC'
                        user.accounting_plan.general_account_providers.to_s.presence || '401000'
                       when 'VT'
                        user.accounting_plan.general_account_customers.to_s.presence || '411000'
                       when 'NDF'
                        '471000'
                       else
                        '512000'
                       end

            line[30] = 'G'
            line[31] = Pack::Report::Preseizure::Account.where(id: preseizure.entries.pluck(:account_id)).where(type: Pack::Report::Preseizure::Account::TTC).first.try(:number)
            line[48] = preseizure.piece_number? ? I18n.transliterate(preseizure.piece_number.to_s) : I18n.transliterate(preseizure.third_party.to_s)
            line[83] = I18n.transliterate(file_name.to_s)

            data << line
          end
      end
    end

    data.join("\n")
  end
end
