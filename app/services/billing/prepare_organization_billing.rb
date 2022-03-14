class Billing::PrepareOrganizationBilling
  def initialize(organization, period)
    @organization = organization
    @period       = period
    @time_end     = Date.parse("#{period.to_s[0..3]}-#{period.to_s[4..5]}-15").end_of_month + 1.day
  end

  def execute
    @organization.billings.of_period(@period).not_frozen.destroy_all
    @customers_ids = @organization.customers.active_at(@time_end).pluck(:id)

    create_basic_discount_billing
    create_retriever_discount_billing
  end

  private

  def create_basic_discount_billing
    customers_count = Management::Package.where(user_id: @customers_ids).where(name: 'ido_classique').count

    price = Package::Pricing.discount_prices(:ido_classique, customers_count, discount_version)

    if discount_version == 2
      customers_count = customers_count - 250
      title = "Offre spéciale : 10€ / dossier après 250 dossiers : #{price} € X #{customers_count}"
    else
      title = "Abo. mensuels : #{price} € X #{customers_count}"
    end


    create_billing({ name: 'basic_discount', title: title, price: (price * customers_count), kind: 'discount' }) if price < 0
  end

  def create_retriever_discount_billing
    customers_count = Management::Package.where(user_id: @customers_ids).where(retriever_option_active: true).count

    price = Package::Pricing.discount_prices(:bank_option, customers_count, discount_version)

    title = "Automates. : #{price} € X #{customers_count}"

    create_billing({ name: 'retriever_discount', title: title, price: (price * customers_count), kind: 'discount' }) if price < 0
  end

  def create_billing(params)
    billing = Finance::Billing.new
    billing.owner  = @organization
    billing.period = @period
    billing.name   = params[:name]
    billing.title  = params[:title]
    billing.kind   = params[:kind] if params[:kind].present?
    billing.associated_hash = params[:associated_hash]
    billing.price  = params[:price] * 100

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