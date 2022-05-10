class BillingMod::PrepareUserBilling
  def initialize(user, period=nil)
    @user   = user
    @period = period || CustomUtils.period_of(Time.now)
  end

  def execute
    return false if !@user.still_active? || @user.is_prescriber

    @package = @user.package_of(@period)
    @package = clone_existing_package if not @package

    return false if not @package

    BillingMod::FetchFlow.new(@period).execute(@user)
    @data_flow = @user.data_flows.of_period(@period).first

    return false if not @data_flow
    return false if @user.pieces.count == 0

    @user.billings.of_period(@period).update_all(is_frozen: true)

    create_package_billing
    create_remaining_month_billing
    create_options_billing
    create_orders_billing
    create_extra_orders_billing
    create_excess_billing

    create_bank_excess_billing
    create_journals_excess_billing

    create_resit_operations_billing
    create_digitize_billing

    @user.billings.of_period(@period).is_frozen.destroy_all
  end

  private

  def create_package_billing
    return true if @package.name == 'ido_premium'

    create_billing({ name: @package.name, title: BillingMod::Configuration::LISTS[@package.name.to_sym][:label], price: @package.base_price })
  end

  def create_remaining_month_billing
    prev_period  = CustomUtils.period_operation(@period, -1)
    prev_package = @user.package_of( prev_period )

    next_period  = CustomUtils.period_operation(@period, 1)
    next_package = @user.package_of( next_period )

    remaining_month = 0
    base_price      = 0

    if prev_package.try(:name) != @package.try(:name) && prev_package.try(:commitment_end_period).to_i >= @period.to_i
      remaining_month = prev_package.try(:commitment_end_period).to_i != @period.to_i ? CustomUtils.period_diff(@period, prev_package.try(:commitment_end_period).to_i) : 1
      base_price      = prev_package.try(:base_price).to_i
      package_name    = prev_package.try(:human_name)
    elsif next_package.try(:name) != @package.try(:name) && @package.try(:commitment_end_period).to_i > @period.to_i
      remaining_month = CustomUtils.period_diff(@period, @package.try(:commitment_end_period).to_i)
      base_price      = @package.try(:base_price).to_i
      package_name    = @package.try(:human_name)
    end

    if remaining_month > 0 && base_price > 0
      create_billing({ name: 'remaining_month', title: "#{package_name} : engagement #{remaining_month} mois restant(s)", kind: 'normal', price: base_price * remaining_month, associated_hash: { remaining_month: remaining_month, price: base_price } })
    end
  end

  def create_options_billing
    @package.options.each do |opt, val|
      next if val != 'optional'

      if opt.to_s == 'bank' && @package.bank_active
        create_billing({ name: 'bank_option', title: 'Option automate / Récupération bancaire', price: BillingMod::Configuration.price_of(:ido_retriever, @user) })
      elsif opt.to_s == 'mail' && @package.mail_active
        create_billing({ name: 'mail_option', title: 'Envoi par courrier A/R', price: BillingMod::Configuration.price_of(:mail) })
      elsif opt.to_s == 'preassignment' && !@package.preassignment_active
        create_billing({ name: 'preassignment_option', title: 'Remise sur pré-affectation', kind: 'discount', price: (BillingMod::Configuration.price_of(:preassignment) * -1) })
      end
    end
  end

  def create_excess_billing
    return false if calculated_excess[:price] <= 0 && calculated_excess[:count] <= 0

    create_billing({ name: 'excess_billing', title: 'Pré-affectation en excès', kind: 'excess', price: calculated_excess[:price], associated_hash: { excess: calculated_excess[:count], price: @package.excess_price } })
  end

  def create_orders_billing
    is_manual_paper_set_order = CustomUtils.is_manual_paper_set_order?(@user.organization)

    @user.orders.of_period(@period).confirmed.each do |order|
      next if order.paper_set? && is_manual_paper_set_order

      if order.dematbox?
        title  = "Commande de #{order.dematbox_count} scanner#{'s' if order.dematbox_count > 1} iDocus'Box"
        name   = "dematbox_order"
      else
        title  = 'Commande de Kit envoi courrier'
        name   = "paper_set_order"
      end

      price = order.price_in_cents_wo_vat / 100
      create_billing({ name: name, title: title, kind: 'order', price: price })
    end
  end

  def create_extra_orders_billing
    @user.extra_orders.of_period(@period).map do |extra_order|
      create_billing({ name: 'extra_order', title: extra_order.name, kind: 'extra', price: extra_order.price })
    end
  end

  def create_bank_excess_billing
    if @data_flow.bank_excess > 0
      price   = BillingMod::Configuration.price_of(:bank_excess)
      create_billing({ name: 'bank_excess', title: "#{@data_flow.bank_excess} compte(s) bancaire(s) supplémentaire(s)", kind: 'excess', price: (price * @data_flow.bank_excess), associated_hash: { excess: @data_flow.bank_excess, price: price } })
    end
  end

  def create_journals_excess_billing
    if @data_flow.journal_excess > 0
      price   = BillingMod::Configuration.price_of(:journal_excess)

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
        create_billing({ name: 'operations_billing', title: title, kind: 're-sit', price: BillingMod::Configuration.price_of(:ido_retriever, @user) })
      end
    end
  end

  def create_digitize_billing
    is_manual_paper_set_order = CustomUtils.is_manual_paper_set_order?(@user.organization)

    if @package.name == 'ido_digitize' || (is_manual_paper_set_order && @package.scan_active)
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
    billing        = @user.billings.where(period: @period, name: params[:name], title: params[:title], kind: (params[:kind] || 'normal' )).first || BillingMod::Billing.new

    billing.owner  = @user
    billing.period = @period
    billing.name   = params[:name]
    billing.title  = params[:title]
    billing.kind   = params[:kind] if params[:kind].present?
    billing.associated_hash = params[:associated_hash] if params[:associated_hash].present?
    billing.price  = params[:price] * 100

    billing.is_frozen = false

    billing.save
  end

  def clone_existing_package
    my_package = @user.my_package
    return nil if not my_package

    next_package        = my_package.dup
    next_package.user   = @user
    next_package.period = @period

    next_package.save

    @user.reload

    next_package
  end

  def calculated_excess
    return @excess_data if @excess_data.present?

    @excess_data = { price: 0, count: 0 }

    return @excess_data if BillingMod::Configuration::LISTS[@package.name.to_sym].try(:[], :cummulative_excess)
    return @excess_data if @package.name == 'ido_premium'

    if @package.excess_duration == 'month'
      data_flow = @user.data_flows.where(period: @package.period).select("compta_pieces as t_compta_pieces, compta_operations as t_compta_operations").first
    else
      current_flow = @user.flow_of(@package.period)
      data_flows   = @user.data_flows.where(period_version: current_flow.period_version).where('period <= ?', @package.period)

      billings     = @user.billings.where(period: data_flows.pluck(:period), name: 'excess_billing')
      total_billed = 0
      billings.each do |billing|
        total_billed += billing.associated_hash[:excess]
      end

      __flow = data_flows.select("SUM(compta_pieces) as t_compta_pieces, SUM(compta_operations) as t_compta_operations").first
      to_billed = __flow.try(:t_compta_pieces).to_i + __flow.try(:t_compta_operations).to_i
      to_billed -= total_billed

      data_flow  = OpenStruct.new(t_compta_pieces: to_billed, t_compta_operations: 0)
    end

    @excess_data[:count] = (data_flow.try(:t_compta_pieces).to_i + data_flow.try(:t_compta_operations).to_i) - @package.flow_limit
    @excess_data[:price] = @package.excess_price * @excess_data[:count] if @package.flow_limit > 0 && @excess_data[:count] > 0

    @excess_data
  end
end