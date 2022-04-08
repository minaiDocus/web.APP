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

  end
end