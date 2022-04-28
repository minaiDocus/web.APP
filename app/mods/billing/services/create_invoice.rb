module BillingMod
  class CreateInvoice
    def initialize(_time=nil, options={})
      @time              = _time.presence || 1.month.ago
      @is_test           = options[:is_test] ? true : false
      @is_update         = options[:is_update] ? true : false
      @notify            = options[:notify] === false ? false : true
      @auto_upload       = options[:auto_upload] === false ? false : true

      @period    = CustomUtils.period_of(@time)
    end

    def execute(organizations=nil)
      @organizations = Array(organizations).presence || Organization.billed

      @organizations.each do |organization|
        @invoice = organization.invoices.of_period(@period).first

        next if organization.code == 'TEEO'
        next if @invoice && !@is_test && !@is_update

        generate_invoice_of(organization)
      end
    end

    private

    def generate_invoice_of(organization)
      @organization = organization
      @customers    = organization.customers.active_at(@time)

      @packages_count       = {}
      @total_customers_price = 0

      @customers.each do |customer|
        next if customer.pieces.count == 0

        package = customer.package_of(@period)

        next if not package

        if @is_update || @period == CustomUtils.period_of(Time.now) || !@invoice
          BillingMod::PrepareUserBilling.new(customer, @period).execute
          BillingMod::PrepareOrganizationBilling.new(customer, @period).execute
        end

        increm_package_count('iDoClassique')  if package.name == 'ido_classic'
        increm_package_count('iDoNano')       if package.name == 'ido_nano'
        increm_package_count('iDoX')          if package.name == 'ido_x'
        increm_package_count('iDoMicro')      if ['ido_micro_plus', 'ido_micro'].include?(package.name)
        increm_package_count('Numérisation')  if package.name == 'ido_digitize'
        increm_package_count('Automates')     if package.retriever_option_active
        increm_package_count('Courriers')     if package.mail_option_active

        @total_customers_price += customer.total_billing_of(@period)
      end

      create_invoice
      generate_pdf
      auto_upload_invoice
      send_notification
    end

    def create_invoice
      if @is_test
        @invoice              = FakeObject.new
        @invoice.created_at   = Time.now
        @invoice.updated_at   = Time.now
        @invoice.number       = "#{@organization.code}_#{@organization.id}"
      else
        @invoice              = @organization.invoices.of_period(@period).first || BillingMod::Invoice.new
      end
      @invoice.vat_ratio      = @organization.subject_to_vat ? 1.2 : 1
      @invoice.period_v2      = @period
      @invoice.organization   = @organization

      total = @total_customers_price + @organization.total_billing_of(@period)
      @invoice.amount_in_cents_w_vat = (total * @invoice.vat_ratio).round

      @invoice.save if not @is_test
    end

    def generate_pdf
      #TO DO: generating invoice pdf
      #classGenerator : return file_path

      invoice_path = Billing::PdfGenerator.new(@organization, @packages_count, @invoice, @total_customers_price, @time).generate

      if not @is_test
        #@invoice.cloud_content_object.attach
      else
        #Test HERE
      end

    end

    def auto_upload_invoice
      if !@is_test && @auto_upload
        begin
          user = User.find_by_code 'ACC%IDO' # Always send invoice to ACC%IDO customer

          file = File.new @invoice.cloud_content_object.path
          content_file_name = @invoice.cloud_content_object.filename

          uploaded_document = UploadedDocument.new( file, content_file_name, user, 'VT', 1, nil, 'invoice_auto', nil )

          auto_upload_invoice_setting(file, content_file_name)
        rescue => e
          System::Log.info('auto_upload_invoice', "[#{Time.now}] - [#{@invoice.id}] - [#{@invoice.organization.id}] - Error: #{e.to_s}")
        end
      end
    end

    def auto_upload_invoice_setting(file, content_file_name)
      if !@is_test && !@is_update && @auto_upload
        invoice_settings = @invoice.organization.invoice_settings || []

        invoice_settings.each do |invoice_setting|
          next unless invoice_setting.user.packages.of_period(@period).upload_active

          uploaded_document = UploadedDocument.new( file, content_file_name, invoice_setting.user, invoice_setting.journal_code, 1, nil, 'invoice_setting', nil )
        end
      end
    end

    def send_notification
      if !@is_test && !@is_update && @notify
        @organization.admins.each do |admin|
         Notifications::Notifier.new.create_notification({
           url: Rails.application.routes.url_helpers.organization_invoices_url({organization_id: @organization.id}.merge(ActionMailer::Base.default_url_options)),
           user: admin,
           notice_type: 'invoice',
           title: "Nouvelle facture disponible",
           message: "Votre facture pour la période de #{@period} est maintenant disponible."
         }, false)
        end

        InvoiceMailer.delay(queue: :high).notify(@invoice)
      end
    end

    def increm_package_count(package_name)
      begin
        @packages_count[package_name] += 1
      rescue
        @packages_count[package_name] = 1
      end
    end
  end

  class PdfGenerator
    def initialize(organization, packages_count, invoice, total_customers_price, time)
      @organization          = organization
      @packages_count        = packages_count
      @invoice               = invoice
      @total_customers_price = total_customers_price
      @time                  = time
      @period                = CustomUtils.period_of(@time)

      @months                = I18n.t('date.month_names').map { |e| e.capitalize if e }
      @period_month          = @months[time.month]
      @year                  = time.year
    end

    def generate
      @pdf.destroy if @pdf

      invoice_path = "#{Rails.root}/tmp/#{@invoice.number}.pdf"

      Prawn::Document.generate(invoice_path, :bottom_margin => 150) do |pdf|
        @pdf = pdf

        @pdf.repeat [1] do
          @pdf.image "#{Rails.root}/app/assets/images/application/bandeau_facture_parrainage.jpg", width: 472, height: 151, align: :center, :at => [35, 10]
        end

        make_header

        make_body

        make_footer

        @pdf
      end

      invoice_path
    end

    private

    def make_header
      address = @organization.addresses.for_billing.first

      @pdf.font 'Helvetica'
      @pdf.fill_color '49442A'

      @pdf.font_size 8
      @pdf.default_leading 4

      header_data = [
        [
          "IDOCUS\n17, rue Galilée\n75116 Paris.",
          "SAS au capital de 50 000 €\nRCS PARIS: 804 067 726\nTVA FR12804067726",
          "contact@idocus.com\nwww.idocus.com\nTél : 01 84 250 251"
        ]
      ]

      @pdf.table(header_data, width: 540) do
        style(row(0), borders: [:top, :bottom], border_color: 'AFA6A6', text_color: 'AFA6A6')
        style(columns(1), align: :center)
        style(columns(2), align: :right)
      end

      @pdf.move_down 10
      @pdf.image "#{Rails.root}/app/assets/images/logo/big_logo.png", width: 90, height: 30, at: [4, @pdf.cursor]

      @pdf.stroke_color '49442A'
      @pdf.font_size 10
      @pdf.default_leading 5

      formatted_address = [address.company, address.first_name + ' ' + address.last_name, address.address_1, address.address_2, address.zip.to_s + ' ' + address.city, address.country]
                          .reject { |a| a.nil? || a.empty? }
                          .join("\n")

      @pdf.bounding_box([262, @pdf.cursor], width: 270) do
        @pdf.text formatted_address, align: :right, style: :bold

        if @organization.vat_identifier
          @pdf.move_down 7

          @pdf.text "TVA : #{@organization.vat_identifier}", align: :right, style: :bold
        end
      end

      @pdf.font_size(14) do
        @pdf.move_down 30
        @pdf.text "Facture n° " + @invoice.number.to_s + ' du ' + (@invoice.created_at - 1.month).end_of_month.day.to_s + ' ' + @period_month + ' ' + (@invoice.created_at - 1.month).year.to_s, align: :left, style: :bold
      end

      @pdf.move_down 14
      @pdf.text "<b>Période concernée :</b> " + @period_month + ' ' + @year.to_s, align: :left, inline_format: true
    end

    def make_body
      @pdf.move_down 30
      data = [['<b>Forfaits & Prestations</b>', '<b>Prix HT</b>']]

      data << ["Nombre de dossiers actifs : #{@organization.customers.active_at(@time)}", '']
      data << ['Forfaits et options iDocus pour ' + @period_month.downcase + ' ' + @year.to_s + ' :', CustomUtils.format_price(@total_customers_price) + " €"]
      

      @packages_count.each do |package|
        if %w(iDoClassique iDoNano iDoX iDoMicro).include?(package)
          data << ["- #{package[1]} forfait#{'s' if package[1] > 1} #{package[0]}", ""]
        else
          data << ["- #{package[1]} option#{'s' if package[1] > 1} #{package[0]}", ""]
        end
      end

      # @organization.billing.where(period: @period).each do |data_organization|
      #   data << ["#{data_organization.title}", "#{CustomUtils.format_price(data_organization.price)}"]
      # end

      data << ['', '']

      @pdf.table(data, width: 540, cell_style: { inline_format: true }) do
        style(row(0..-1), borders: [], text_color: '49442A')
        style(row(0), borders: [:bottom])
        style(row(-1), borders: [:bottom])
        style(columns(2), align: :right)
        style(columns(1), align: :right)
      end
    end

    def make_footer
      total = @total_customers_price # + @organization.total_billing_of(@period)

      @pdf.move_down 7
      @pdf.float do
        @pdf.text_box 'Total HT', at: [400, @pdf.cursor], width: 60, align: :right, style: :bold
      end
      @pdf.text_box CustomUtils.format_price(total) + " €", at: [470, @pdf.cursor], width: 66, align: :right
      @pdf.move_down 10
      @pdf.stroke_horizontal_line 470, 540, at: @pdf.cursor

      @pdf.move_down 7
      @pdf.float do
        if @invoice.organization.subject_to_vat
          @pdf.text_box 'TVA (20%)', at: [400, @pdf.cursor], width: 60, align: :right, style: :bold
        else
          @pdf.text_box 'TVA (0%)', at: [400, @pdf.cursor], width: 60, align: :right, style: :bold
        end
      end
      if @invoice.organization.subject_to_vat
        @pdf.text_box CustomUtils.format_price(total * @invoice.vat_ratio - total) + " €", at: [470, @pdf.cursor], width: 66, align: :right
      else
        @pdf.text_box "0 €", at: [470, @pdf.cursor], width: 66, align: :right
      end
      @pdf.move_down 10
      @pdf.stroke_horizontal_line 470, 540, at: @pdf.cursor

      @pdf.move_down 7
      @pdf.float do
        @pdf.text_box 'Total TTC', at: [400, @pdf.cursor], width: 60, align: :right, style: :bold
      end
      if @invoice.organization.subject_to_vat
        @pdf.text_box CustomUtils.format_price(total * @invoice.vat_ratio) + " €", at: [470, @pdf.cursor], width: 66, align: :right
      else
        @pdf.text_box CustomUtils.format_price(total) + " €", at: [470, @pdf.cursor], width: 66, align: :right
      end
      @pdf.move_down 10
      @pdf.stroke_color '000000'
      @pdf.stroke_horizontal_line 470, 540, at: @pdf.cursor

      # Other information
      @pdf.move_down 13
      @pdf.text "Cette somme sera prélevée sur votre compte le 4 #{@months[@invoice.created_at.month].downcase} #{@invoice.created_at.year}"

      if @invoice.organization.vat_identifier && !@invoice.organization.subject_to_vat
        @pdf.move_down 7
        @pdf.text 'Auto-liquidation par le preneur - Art 283-2 du CGI'
      end

      @pdf.move_down 7
      @pdf.text "<b>Retrouvez le détails de vos consommations dans votre espace client dans le menu \"Mon Reporting\".</b>", align: :center, inline_format: true
    end
  end
end