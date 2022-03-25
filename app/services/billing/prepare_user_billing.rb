class Billing::PrepareUserBilling
  def initialize(user, period)
    @user   = user
    @period = period
  end

  def execute
    DataProcessor::DataFlow.execute(@user)

    @user.billings.of_period(@period).not_frozen.destroy_all
    @package   = @user.packages.of_period(@period).first
    @data_flow = @user.data_flows.of_period(@period).first

    create_package_billing
    create_options_billing
    create_orders_billing
    create_excess_billing

    create_bank_excess_billing
    create_journals_excess_billing

    create_resit_operations_billing
    create_digitize_billing
  end

  private

  def create_package_billing
    create_billing({ name: @package.name, title: @package.human_name, price: @package.base_price })
  end

  def create_options_billing
    @package.options.each do |opt, val|
      next if val != 'optional'

      if opt.to_s == 'bank' && @package.bank_active
        create_billing({ name: 'bank_option', title: 'Option automate', price: Package::Pricing.price_of(:ido_retriever, @user) })
      elsif opt.to_s == 'mail' && @package.mail_active
        create_billing({ name: 'mail_option', title: 'Option courrier', price: Package::Pricing.price_of(:mail) })
      elsif opt.to_s == 'preassignment' && !@package.preassignment_active
        create_billing({ name: 'preassignment_option', title: 'Remise sur pré-affectation', kind: 'discount', price: (Package::Pricing.price_of(:preassignment) * -1) })
      end
    end
  end

  def create_excess_billing
    return false if calculated_excess[:price] <= 0 && calculated_excess[:count] <= 0

    create_billing({ name: 'excess_billing', title: 'Pré-affectation en excès', kind: 'excess', price: calculated_excess[:price], associated_hash: { excess: calculated_excess[:count], price: @package.excess_price } })
  end

  def create_orders_billing
    is_manual_paper_set_order = CustomUtils.is_manual_paper_set_order?(@user.organization)
    #TO DO: orders billing
  end

  def create_bank_excess_billing
    if @data_flow.bank_excess > 0
      price   = Package::Pricing.price_of(:bank_excess)
      create_billing({ name: 'bank_excess', title: "#{@data_flow.bank_excess} compte(s) bancaire(s) supplémentaire(s)", kind: 'excess', price: (price * @data_flow.bank_excess), associated_hash: { excess: @data_flow.bank_excess, price: price } })
    end
  end

  def create_journals_excess_billing
    if @data_flow.journal_excess > 0
      price   = Package::Pricing.price_of(:journal_excess)

      create_billing({ name: 'journal_excess', title: "#{@data_flow.journal_excess} journal(aux) comptable(s) supplémentaire(s)", kind: 'excess', price: (price * @data_flow.journal_excess), associated_hash: { excess: @data_flow.journal_excess, price: price } })
    end
  end

  def create_resit_operations_billing
    operations_periods = @user.operations.where.not(processed_at: nil).where("is_locked = false AND DATE_FORMAT(created_at, '%Y%m') = #{@period}").map{ |ope| ope.date.strftime('%Y%m').to_i }.uniq

    operations_periods.each do |_period|
      next if @period <= _period

      title     = "Opérations bancaires mois de #{I18n.l(Date.new(_period.to_s[0..3].to_i, _period.to_s[4..-1].to_i), format: '%B')} #{_period.to_s[0..3].to_i}"
      billing   = @user.billings.of_period(_period).where(name: ['ido_retriever', 'bank_option']).first
      billing ||= @user.billings.of_period(_period).where(name: 'operations_billing', kind: 're-sit', title: title).first

      if not billing
        create_billing({ name: 'operations_billing', title: title, kind: 're-sit', price: Package::Pricing.price_of(:ido_retriever, @user) })
      end
    end
  end

  def create_digitize_billing
    if @package.name == 'ido_digitize'
      if @data_flow.scanned_sheets > 0
        #### ------- Scanned sheet Option -------- ####
        price = 0.1
        create_billing({ name: 'scanned_sheets', title: "#{@data_flow.scanned_sheets} feuille(s) numérisée(s)", price: (@data_flow.scanned_sheets * price), associated_hash: { excess: @data_flow.scanned_sheets, price: price } })

        #### --------- Pack size Option -------- ####
        pack_names = @user.paper_processes.where('DATE_FORMAT(created_at, "%Y%m") = ?', @period).where(type: 'scan').select(:pack_name).distinct
        pack_size  = pack_names.collect(&:pack_name).size

        if pack_size > 0
          price = 1
          create_billing({ name: 'paper_processes', title: "#{pack_size} pochette(s) scannée(s)", price: (pack_size * price), associated_hash: { excess: pack_size, price: price } })
        end
      end
    end
  end

  def create_billing(params)
    billing = Finance::Billing.new
    billing.owner  = @user
    billing.period = @period
    billing.name   = params[:name]
    billing.title  = params[:title]
    billing.kind   = params[:kind] if params[:kind].present?
    billing.associated_hash = params[:associated_hash] if params[:associated_hash].present?
    billing.price  = params[:price] * 100

    billing.save
  end

  def calculated_excess
    return @excess_data if @excess_data.present?

    @excess_data = { price: 0, count: 0 }

    if @package.excess_duration == 'month'
      data_flow = @user.data_flows.where(period: @package.period).select("compta_pieces as t_compta_pieces, compta_operations as t_compta_operations").first
    else
      periods   = @user.packages.where(name: @package.name, version: @package.version).pluck(:period) - @user.billings.where(name: 'excess_billing').pluck(:period)
      data_flow = @user.data_flows.where(period: periods).select("SUM(compta_pieces) as t_compta_pieces, SUM(compta_operations) as t_compta_operations").first
    end

    @excess_data[:count] = (data_flow.try(:t_compta_pieces).to_i + data_flow.try(:t_compta_operations).to_i) - @package.flow_limit
    @excess_data[:price] = @package.excess_price * @excess_data[:count] if @package.flow_limit > 0 && @excess_data[:count] > 0

    @excess_data
  end
end