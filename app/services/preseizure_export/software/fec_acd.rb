class PreseizureExport::Software::FecAcd
  def self.file_name_format(piece)
    piece.name.to_s[-10, 10].tr(' ', '_').tr('%', '_') + '.pdf'
  end

  def initialize(preseizures, tmp_dir=nil, _format='txt')
    @preseizures = preseizures
    @user        = preseizures.first.user
    @dir         = tmp_dir.presence || CustomUtils.mktmpdir('fec_acd')

    @format      = _format
  end

  def execute
    return 'not_authorized' if not @user.uses?(:fec_acd)

    @base_name = @preseizures.first.report.name.tr(' ', '_').tr('%', '_')
    @file_path = "#{@dir}/#{@base_name}.txt"

    File.open(@file_path, 'w'){ |file| file.write(datas) }

    @file_path
  end

  private

  def datas
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

              unless is_provider
                accounting = user.accounting_plan.customers.where(third_party_account: auxiliary_account).limit(1)
                is_customer = accounting.size > 0
              end

              general_account = if is_provider
                                  user.accounting_plan.general_account_providers.presence || 40_100_001
                                elsif is_customer
                                  user.accounting_plan.general_account_customers.presence || 41_100_001
                                else
                                  auxiliary_account
                                end


              auxiliary_account = ''                                unless is_provider || is_customer
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

          if preseizure.piece
            piece_ref = PreseizureExport::Software::FecAcd.file_name_format(preseizure.piece).gsub('.pdf', '')
          else
            piece_ref = "#{preseizure.report.name.to_s[-6, 10].tr(' ', '_').tr('%', '_')}_#{("%03d" % preseizure.position)}"
          end

          label = preseizure.piece_number
          label = preseizure.operation_label[0..34].gsub("\t", ' ') if preseizure.operation_label.present?

          journal_code   = preseizure.journal_name || ""
          journal_lib    = user.account_book_types.where(name: journal_code).first.try(:description).try(:gsub, "\t", ' ').try(:tr, '()', '  ') || ""
          ecriture_num   = ""
          ecriture_date  = preseizure.computed_date.strftime('%Y%m%d') || ""
          compte_num     = general_account || ""
          compte_lib     = general_lib
          comp_aux       = auxiliary_account || ""
          comp_aux_lib   = auxiliary_lib || ""
          piece_ref      = piece_ref || ""
          piece_date     = preseizure.computed_date.strftime('%Y%m%d') || ""
          ecriture_libc  = label || ""
          debit_credit   = entry.type == 1 ? entry.amount.to_f.to_s + "|" : "|" + entry.amount.to_f.to_s
          ecriture_let   = account.lettering || ""
          date_let       = ""
          valid_date     = ""
          montant_devise = preseizure.amount.to_f.to_s || ""
          idevise        = preseizure.amount.to_f > 0 ? preseizure.currency.to_s : ""
          mouvement_ecriture = (preseizure.piece)? ( [preseizure.piece_number, preseizure.third_party].join(' - ') ) : label

          if entry.amount
            data << [[journal_code, journal_lib, ecriture_num, ecriture_date, compte_num, compte_lib, comp_aux, comp_aux_lib, piece_ref, piece_date, ecriture_libc, debit_credit, ecriture_let, date_let, valid_date, montant_devise, idevise, mouvement_ecriture].join("|")]
          end
        end
      end
    end

    data.join("\n")
  end
end