class BillingMod::PrepareOrganizationBilling
  def initialize(organization, period=nil)
    @organization = organization
    @period       = period.presence || CustomUtils.period_of(Time.now)
    @time_end     = Date.parse("#{@period.to_s[0..3]}-#{@period.to_s[4..5]}-15").end_of_month + 1.day
  end

  def execute
    @organization.billings.of_period(@period).update_all(is_frozen: true)
    @customers_ids = []
    @organization.customers.active_at(@time_end).each do |customer|
      next if customer.pieces.count == 0

      @customers_ids << customer.id
    end

    create_classic_discount_billing
    create_retriever_discount_billing
    create_classic_excess_billing
    create_micro_plus_excess_billing
    create_extra_order_billing

    @organization.billings.of_period(@period).is_frozen.destroy_all
  end

  private

  def create_classic_discount_billing
    customers_count = BillingMod::Package.of_period(@period).where(user_id: @customers_ids).where(name: 'ido_classic').count

    price = BillingMod::Configuration.discount_price(:ido_classic, customers_count, discount_version)

    # if price < 0
      if discount_version == 2
        customers_count = customers_count - 250
        title = "Offre spéciale : 10€ / dossier après 250 dossiers : #{price} € X #{customers_count}"
      else
        title = "Abo. mensuels : #{price} € X #{customers_count}"
      end
    # else
    #   title = "- #{ (discount_version == 1)? '75' : '250' } dossiers"
    # end

    create_billing({ name: 'classic_discount', title: title, price: (price * customers_count), kind: 'discount' }) if price < 0
  end

  def create_retriever_discount_billing
    customers_count = BillingMod::Package.of_period(@period).where(user_id: @customers_ids).where(bank_active: true).count

    price = BillingMod::Configuration.discount_price(:bank_option, customers_count, discount_version)

    title = "Automates. : #{price} € X #{customers_count}"

    create_billing({ name: 'retriever_discount', title: title, price: (price * customers_count), kind: 'discount' }) if price < 0
  end

  def create_classic_excess_billing
    customers_id = BillingMod::Package.of_period(@period).where(user_id: @customers_ids).where(name: 'ido_classic').pluck(:user_id)

    excess_limit        = BillingMod::Configuration.flow_limit_of('ido_classic')
    all_excess_limit    = excess_limit * customers_id.size
    total_compta_pieces = BillingMod::DataFlow.of_period(@period).where(user_id: customers_id).select('SUM(compta_pieces) as compta_pieces').first.compta_pieces.to_i
    excess              = total_compta_pieces - all_excess_limit
    price               = BillingMod::Configuration.excess_price_of('ido_classic')

    create_billing({ name: 'ido_classic_excess', title: 'Documents classiques en excès', kind: 'excess', price: ( price * excess ), associated_hash: { excess: excess, price: price, limit: all_excess_limit } }) if excess > 0
  end

  def create_micro_plus_excess_billing
    customers_id = BillingMod::Package.of_period(@period).where(user_id: @customers_ids).where(name: 'ido_micro_plus').pluck(:user_id)

    excess_limit        = BillingMod::Configuration.flow_limit_of('ido_micro_plus')
    all_excess_limit    = excess_limit * customers_id.size
    total_compta_pieces = BillingMod::DataFlow.of_period(@period).where(user_id: customers_id).select('SUM(compta_pieces) as compta_pieces').first.compta_pieces.to_i
    excess              = total_compta_pieces - all_excess_limit
    price               = BillingMod::Configuration.excess_price_of('ido_micro_plus')

    create_billing({ name: 'ido_micro_plus_excess', title: 'Documents micro en excès', kind: 'excess', price: ( price * excess ), associated_hash: { excess: excess, price: price, limit: all_excess_limit } }) if excess > 0
  end

  def create_extra_order_billing
    #TODO : Find a way to remove SubscriptionOption, instead use direclty ExtraOrder
    options = @organization.subscription.options.where(period_duration: 0)
    options.each do |option|
      extra_order        = @organization.extra_orders.where(name: option.name).first || BillingMod::ExtraOrder.new
      extra_order.period = @period
      extra_order.owner  = @organization
      extra_order.name   = option.name
      extra_order.price  = option.price_in_cents_wo_vat / 100

      extra_order.save
    end

    @organization.reload.extra_orders.of_period(@period).map do |extra_order|
      create_billing({ name: 'extra_order', title: extra_order.name, kind: 'extra', price: extra_order.price })
    end
  end

  def create_billing(params)
    billing        = @organization.billings.where(period: @period, name: params[:name], title: params[:title], kind: (params[:kind] || 'normal' )).first || BillingMod::Billing.new

    billing.owner  = @organization
    billing.period = @period
    billing.name   = params[:name]
    billing.title  = params[:title]
    billing.kind   = params[:kind] if params[:kind].present?
    billing.associated_hash = params[:associated_hash]
    billing.price  = params[:price] * 100

    billing.is_frozen = false

    billing.save
  end

  def discount_version
    if ['GMBA', 'CEN'].include? @organization.code
      2
    else
      1
    end
  end
end