# -*- encoding : UTF-8 -*-
class SoftwareMod::Service::FecAgiris
  def self.file_name_format(piece)
    "#{piece.position.to_s[0..25]}.pdf"
  end

  def initialize(preseizures, tmp_dir=nil, _format='txt')
    @preseizures = preseizures
    @user        = preseizures.first.user
    @dir         = tmp_dir.presence || CustomUtils.mktmpdir('fec_agiris')

    @format      = _format
  end

  def execute
    return 'not_authorized' if not @user.uses?(:fec_agiris)

    @base_name = @preseizures.first.report.name.tr(' ', '_').tr('%', '_')
    
    if @format == 'ecr'
      @file_path = to_ecr
    else
      @file_path = to_txt
    end

    @file_path
  end

  private

  def to_txt
    file_path = "#{@dir}/#{@base_name}.txt"

    File.open(file_path, 'w'){ |file| file.write(datas_txt) }

    file_path
  end

  def to_ecr
    file_path = "#{@dir}/#{@base_name}.ecr"

    File.open(file_path, 'w'){ |file| file.write(datas_ecr) }

    file_path
  end

  def datas_txt
    data = []

    if @preseizures.any?
      data << "JournalCode|JournalLib|EcritureNum|EcritureDate|CompteNum|CompteLib|CompAuxNum|CompAuxLib|PieceRef|PieceDate|EcritureLibc|Debit|Credit|EcritureLet|DateLet|ValidDate|Montantdevise|Idevise|MouvementEcriture"

      @preseizures.each do |preseizure|
        user = preseizure.user
        journal = preseizure.report.journal({name_only: false})

        preseizure.accounts.each do |account|
          entry = account.entries.first

          if preseizure.piece_id.present?
            general_account = if(account.type == Pack::Report::Preseizure::Account::TVA)
                                journal.try(:get_vat_accounts_of, '0')
                              elsif(account.type == Pack::Report::Preseizure::Account::TTC)
                                journal.try(:account_number)
                              else
                                journal.try(:charge_account)
                              end
          else
            bank_account = preseizure.operation.try(:bank_account)

            general_account = if(
                                  (preseizure.operation.try(:amount).to_i < 0 && entry.credit?) ||
                                  (preseizure.operation.try(:amount).to_i >= 0 && entry.debit?)
                                )
                                bank_account.try(:accounting_number) || 512_000
                              else
                                bank_account.try(:temporary_account) || 471_000
                              end
          end

          auxiliary_account = (general_account.to_s != account.number.to_s)? account.number : ''
          auxiliary_lib     = ""

          if auxiliary_account.present?
            if preseizure.piece_id.present?
              accounting = user.accounting_plan.providers.where(third_party_account: auxiliary_account).limit(1)
              is_provider = accounting.size > 0
              general_account = user.accounting_plan.general_account_providers.presence || 40_100_001 if is_provider

              unless is_provider
                accounting = user.accounting_plan.customers.where(third_party_account: auxiliary_account).limit(1)
                is_customer = accounting.size > 0
                general_account = user.accounting_plan.general_account_customers.presence || 41_100_001 if is_customer
              end

              general_account = auxiliary_account if general_account.blank? || (!is_provider && !is_customer)

              auxiliary_account = ''                                if general_account == auxiliary_account
              auxiliary_lib     = accounting.first.third_party_name if is_provider || is_customer
            else
              if general_account != bank_account.try(:accounting_number) && general_account != 512_000
                general_account = if entry.debit?
                                    user.accounting_plan.general_account_providers.presence || 40_100_001
                                  else
                                    user.accounting_plan.general_account_customers.presence || 41_100_001
                                  end
              end
            end
          else
            accounting = user.accounting_plan.providers.where(third_party_account: general_account).limit(1)

            if accounting.size == 0
              accounting = user.accounting_plan.customers.where(third_party_account: general_account).limit(1)
            end

            general_lib = accounting.try(:first).try(:third_party_name).to_s
          end

          label = preseizure.piece.try(:name)
          label = preseizure.operation_label[0..34].gsub("\t", ' ') if preseizure.operation_label.present?

          journal_code   = preseizure.journal_name || ""
          journal_lib    = user.account_book_types.where(name: journal_code).first.try(:description).try(:gsub, "\t", ' ').try(:tr, '()', '  ') || ""
          ecriture_num   = ""
          ecriture_date  = preseizure.computed_date.strftime('%Y%m%d') || ""
          compte_num     = general_account || ""
          compte_lib     = general_lib
          comp_aux       = auxiliary_account || ""
          comp_aux_lib   = auxiliary_lib || ""
          piece_ref      = preseizure.piece_number || ""
          piece_date     = preseizure.computed_date.strftime('%Y%m%d') || ""
          ecriture_libc  = label || ""          
          debit_credit   = entry.type == 1 ? entry.amount.to_f.to_s + "|" : "|" + entry.amount.to_f.to_s
          ecriture_let   = account.lettering || ""
          date_let       = ""
          valid_date     = ""
          montant_devise = preseizure.amount.to_f.to_s || ""
          idevise        = preseizure.amount.to_f > 0 ? preseizure.currency.to_s : ""
          mouvement_ecriture = preseizure.third_party

          data << [[journal_code, journal_lib, ecriture_num, ecriture_date, compte_num, compte_lib, comp_aux, comp_aux_lib, piece_ref, piece_date, ecriture_libc, debit_credit, ecriture_let, date_let, valid_date, montant_devise, idevise, mouvement_ecriture].join("\t")]
        end
      end
    end

    data.join("\n")
  end

  def datas_ecr
    data = []

    if @preseizures.any?
      @preseizures.each do |preseizure|
        user          = preseizure.user
        journal_name  = preseizure.report.journal({name_only: false}).try(:name) || preseizure.journal_name
        piece         = preseizure.piece

        if piece
          #Insert ECR metadata
          line          = ' ' * 270
          line[0..5]    = "ECR"
          line[6..24]   = "#{journal_name.to_s[0..10]}#{piece.created_at.strftime('%d%m%Y')}" || ""
          line[25..77]  = preseizure.third_party.to_s[0..51] || ""
          line[78..93]  = '1'
          line[94..122] = Time.now.strftime("0%d%m%Y%d%m%Y")
          line[123..152]= "0EUR"
          line[153]     = SoftwareMod::Service::FecAgiris.file_name_format(piece)

          data << line
        end

        preseizure.accounts.each do |account|
          entry         = account.entries.first
          debit_amount  = ''
          credit_amount = ''

          debit_amount  = entry.amount.to_s if entry.debit?
          credit_amount = entry.amount.to_s if entry.credit?

          label = preseizure.piece_number
          label = preseizure.operation_label[0..34].gsub("\t", ' ') if preseizure.operation_label.present?

          line          = ' ' * 270
          line[0..5]    = 'MVT'
          line[6..16]   = account.number.to_s[0..10]
          line[17..47]  = preseizure.third_party.to_s[0..29] || ""
          line[48..61]  = debit_amount.to_s[0..10]
          line[62..97]  = credit_amount.to_s[0..10]
          line[98]      = label.to_s[0..45]

          data << line
        end
      end
    end

    data.join("\n")
  end
end