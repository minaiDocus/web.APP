# -*- encoding : UTF-8 -*-
class BillingMod::BillingToXls
  def initialize(customers_ids, year, with_organization_info = false)
    @year                   = year
    @customers_ids          = customers_ids
    @with_organization_info = with_organization_info
  end

  def execute
    @book = Spreadsheet::Workbook.new

    # Document
    generate_production_datas

    # Invoice
    generate_invoice_datas

    io = StringIO.new('')
    @book.write(io)
    io.string
  end

  private

  def generate_production_datas
    sheet1 = @book.create_worksheet name: 'Production'

    headers = []
    headers << 'Organisation' if @with_organization_info
    headers += [
      'Mois',
      'Année',
      'Code client',
      'Société',
      'Nom du document',
      'Piéces total',
      'Pré-affectation',
      'Opération',
      'Piéces numérisées',
      'Piéces versées',
      'Piéces iDocus\'Box',
      'Piéces automatique',
      'Feuilles numérisées',
      'Pages total',
      'Pages numérisées',
      'Pages versées',
      'Pages iDocus\'Box',
      'Pages automatique',
      'Attache',
      'Hors format'
    ]
    sheet1.row(0).concat headers

    @list       = []

    12.times do |month_ind|
      month_ind += 1
      real_month_ind = (sprintf '%02d', month_ind)

      _period     = "#{@year}#{real_month_ind}".to_i
      _date_end   = Date.parse("#{@year}-#{real_month_ind}-01").to_date.end_of_month

      next if _period > Time.now.strftime('%Y%m').to_i

      @customers       = User.where(id: @customers_ids).active_at(_date_end)
      period_documents = PeriodDocument.where(user_id: @customers_ids).of_period(_period).order(created_at: :asc, name: :asc)
      data_flows       = BillingMod::DataFlow.of_period(_period).where(user_id: @customers_ids)

      report_ids       = Pack::Report.where(document_id: period_documents.pluck(:id)).pluck(:id)
      preseizures      = Pack::Report::Preseizure.unscoped.where(report_id: report_ids).where.not(piece_id: nil)
      expenses         = Pack::Report::Expense.unscoped.where(report_id: report_ids)

      @customers.each do |user|
        documents        = period_documents.to_a.extract!{ |doc| doc.user_id == user.id }
        @operation_count = data_flows.to_a.extract!{|df| df.user_id == user.id}.first.try(:compta_operations).to_i

        if documents.any?
          documents.each do |document|
            @preseizures_count = preseizures.to_a.extract!{|pres| pres.report_id == document.report.try(:id)}.size + expenses.to_a.extract!{|exp| exp.report_id == document.report.try(:id)}.size
            fill_data_with(user, month_ind, document)
          end
        else
          @preseizures_count = 0
          fill_data_with(user, month_ind)
        end
      end
    end

    range = @with_organization_info ? 0..5 : 0..4
    month_index = @with_organization_info ? 1 : 0
    #list = list.sort do |a, b|
    #  _a = a[range]
    #  _b = b[range]
    #  _a[month_index] = ("%02d" % _a[month_index])
    #  _b[month_index] = ("%02d" % _b[month_index])
    #  _a <=> _b
    #end

    @list.each_with_index do |data, index|
      sheet1.row(index + 1).replace(data)
    end
  end

  def generate_invoice_datas
    sheet2 = @book.create_worksheet name: 'Facturation'

    headers = []
    headers << 'Organisation' if @with_organization_info
    headers += [
      'Mois',
      'Année',
      'Code client',
      'Nom du client',
      'Paramètre',
      'Valeur',
      'Prix HT'
    ]
    sheet2.row(0).concat headers

    @list = []

    12.times do |month_ind|
      month_ind += 1
      real_month_ind = (sprintf '%02d', month_ind)

      _period     = "#{@year}#{real_month_ind}".to_i
      _date_end   = Date.parse("#{@year}-#{real_month_ind}-01").to_date.end_of_month

      next if _period > Time.now.strftime('%Y%m').to_i

      @customers    = User.where(id: @customers_ids).active_at(_date_end)
      all_billings  = BillingMod::Billing.of_period(_period).where(owner_id: @customers_ids, owner_type: 'User')

      @customers.each do |user|
        billings  = all_billings.to_a.extract!{|bl| bl.owner_id == user.id}

        next if billings.size == 0 

        billings.each do |billing|
          data = []
          data << user.try(:organization).try(:name) if @with_organization_info

          group_title = BillingMod::Configuration::LISTS[billing.name.to_sym].try(:[], :human_name).presence || billing.title
          title       = group_title != billing.title ? billing.title : ''

          data += [
                    month_ind,
                    @year,
                    user.try(:code).to_s,
                    user.try(:name).to_s,
                    group_title,
                    title,
                    format_price(billing.price)
                  ]

          @list << data
        end
      end
    end

    range = @with_organization_info ? 0..3 : 0..2
    month_index = @with_organization_info ? 1 : 0
    @list = @list.sort do |a, b|
      _a = a[range]
      _b = b[range]
      _a[month_index] = ("%02d" % _a[month_index])
      _b[month_index] = ("%02d" % _b[month_index])
      _a <=> _b
    end

    @list.each_with_index do |data, index|
      sheet2.row(index + 1).replace(data)
    end
  end

  def format_price(price_in_cents)
    ('%0.2f' % (price_in_cents.round / 100.0)).tr('.', ',')
  end

  def fill_data_with(user=nil, month_index=nil, document=nil)
    data = []
    data << user.try(:organization).try(:name) if @with_organization_info
    data += [
              month_index,
              @year,
              user.try(:code),
              user.try(:company),
              document.try(:name),
              document.try(:pieces),
              @preseizures_count,
              @operation_count,
              document.try(:scanned_pieces).to_i,
              document.try(:uploaded_pieces).to_i,
              document.try(:dematbox_scanned_pieces).to_i,
              document.try(:retrieved_pieces).to_i,
              document.try(:scanned_sheets).to_i,
              document.try(:pages).to_i,
              document.try(:scanned_pages).to_i,
              document.try(:uploaded_pages).to_i,
              document.try(:dematbox_scanned_pages).to_i,
              document.try(:retrieved_pages).to_i,
              document.try(:paperclips).to_i,
              document.try(:oversize).to_i
            ]
    @list << data
  end
end
