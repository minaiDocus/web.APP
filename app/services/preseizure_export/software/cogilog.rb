# -*- encoding : UTF-8 -*-
# Generates a ZIP to import in Cogiog
class PreseizureExport::Software::Cogilog
  def initialize(preseizures, tmp_dir=nil, _format='txt')
    @preseizures = preseizures
    @user        = preseizures.first.user
    @dir         = tmp_dir.presence || CustomUtils.mktmpdir('cogilog')

    @format      = _format
  end

  def execute
    return 'not_authorized' if not @user.uses?(:cogilog)

    @base_name = @preseizures.first.report.name.tr(' ', '_').tr('%', '_')
    @file_path = "#{@dir}/#{@base_name}.txt"

    File.open(@file_path, 'w'){ |file| file.write(datas) }

    @file_path
  end

  private

  def datas
    data = []

    if @preseizures.any?
      data << "Journal\tDate\tPièce\tCompte\tSection\tLibellé\tEchéance\tDebit\tCrédit\tIntitulé Journal\tIntitulé Compte\tIntitulé section\tLettrage\tPointage\tCode Fin\tRéférence\tInformations\tVierge\tVierge\tVierge\tVierge\tLien"

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
          general_account   = auxiliary_account if auxiliary_account.present?

          accounting = user.accounting_plan.providers.where(third_party_account: general_account).limit(1)

          if accounting.size == 0
            accounting = user.accounting_plan.customers.where(third_party_account: general_account).limit(1)
          end

          general_lib = accounting.try(:first).try(:third_party_name).to_s


          journal_code     = journal.name
          ecriture_date    = preseizure.computed_date.strftime('%d/%m/%Y') || ""
          piece_ref        = preseizure.piece_number || ""
          compte_num       = general_account || ""
          section          = ""
          compte_lib       = general_lib
          echance_date     = preseizure.computed_deadline_date.try(:strftime, '%d/%m/%Y')
          debit_credit     = entry.type == 1 ? entry.amount.to_f.to_s + "\t" : "\t" + entry.amount.to_f.to_s
          intitule_journal = ""
          intitule_compte  = ""
          intitule_section = ""
          ecriture_let     = account.lettering || ""
          pointage         = ""
          code_fin         = ""
          reference        = ""
          informations     = ""
          vierge           = ""
          vierge           = ""
          vierge           = ""
          vierge           = ""
          lien             = preseizure.piece_id.present? ? Domains::BASE_URL + preseizure.piece.try(:get_access_url) : ""

          data << [[journal_code, ecriture_date, piece_ref, compte_num, section, compte_lib, echance_date, debit_credit, intitule_journal, intitule_compte, intitule_section, ecriture_let, pointage, code_fin, reference, informations, vierge, vierge , vierge, vierge, lien ].join("\t")]

        end
      end
    end

    data.join("\n")
  end
end
