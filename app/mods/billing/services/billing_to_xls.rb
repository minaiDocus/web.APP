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
      _period = "#{@year}#{(sprintf '%02d', month_ind)}".to_i

      next if _period > Time.now.strftime('%Y%m').to_i

      @customers_ids.each do |c_id|
        user = User.find c_id
        next if not user.active_at?(_period)

        documents        = user.period_documents.of_period(_period).order(created_at: :asc, name: :asc)
        @operation_count = user.operations.where("DATE_FORMAT(created_at, '%Y%m') = #{_period}").count

        if documents.any?
          documents.each do |document|
            @preseizures_count = document.report ? (Pack::Report::Preseizure.unscoped.where(report_id: document.report).where.not(piece_id: nil).count  + document.report.expenses.count) : 0
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
      _period = "#{@year}#{(sprintf '%02d', month_ind)}".to_i

      next if _period > Time.now.strftime('%Y%m').to_i

      @customers_ids.each do |c_id|
        user = User.find c_id

        package   = user.package_of(_period)
        data_flow = user.data_flows.of_period(_period).first

        next if !package && _period >= 202205
        next if !data_flow && _period >= 202205
        next if not user.can_be_billed?
        next if not user.active_at?(_period)

        billings = user.billings.of_period(_period)
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
