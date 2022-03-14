class Billing::CreateInvoice
  def initialize(_time=nil, options={})
    @time    = _time.presence || 1.month.ago
    @is_test = options[:is_test] ? true : false
    @is_update = options[:is_update] ? true : false

    @period  = CustomUtils.period_of(@time)
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
    customers = organization.customers.active_at(@time)

    @packages_count       = {}
    @total_packages_price = 0

    customers.each do |customer|
      if @is_update || @period == CustomUtils.period_of(Time.now) || !@invoice
        Billing::PrepareUserBilling.new(customer, @period)
        Billing::PrepareOrganizationBilling.new(customer, @period)
      end

      package = customer.packages.of_period(@period).first

      if package.retriever_option_active
      elsif package.mail_option_active
      elsif package.scan_option_active


        begin
          @packages_count[package_name] += 1
        rescue
          @packages_count[package_name] = 1
        end
      end
    end
  end
end