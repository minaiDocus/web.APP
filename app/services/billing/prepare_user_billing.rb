class Billing::PrepareUserBilling
  def initialize(user, period)
    @user   = user
    @period = period
  end

  def execute
    DataFlowService::Calculator.execute(@user)

    @user.billings.of_period(@period).not_frozen.destroy_all
    @package   = @user.packages.of_period(@period)
    @data_flow = @user.data_flows.of_period(@period) 

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
    billing = Finance::Billing.new

    billing.owner = @user
    billing.period = @period
    billing.name  = @package.name
    billing.title = @package.human_name
    billing.price = @package.base_price * 100

    billing.save
  end

  def create_options_billing
    @package.options.each do |opt, val|
      next if val != 'optional'

      if opt.to_s == 'bank' && @package.bank_active
        billing = Finance::Billing.new

        billing.owner = @user
        billing.period = @period
        billing.name  = 'bank_option'
        billing.title = 'Option automate'
        billing.price = Package::Pricing.price_of(:ido_retriever) * 100

        billing.save
      elsif opt.to_s == 'mail' && @package.mail_active
        billing = Finance::Billing.new

        billing.owner = @user
        billing.period = @period
        billing.name  = 'mail_option'
        billing.title = 'Option courrier'
        billing.price = Package::Pricing.price_of(:mail) * 100

        billing.save
      elsif opt.to_s == 'preassignment' && !@package.is_preassignment_active
        billing = Finance::Billing.new

        billing.owner = @user
        billing.period = @period
        billing.name  = 'preassignment_option'
        billing.kind  = 'discount'
        billing.title = 'Remise sur Pré-affectation'
        billing.price = (Package::Pricing.price_of(:preassignment) * 100) * -1

        billing.save
      end
    end
  end

  def create_excess_billing
    billing = Finance::Billing.new

    billing.owner = @user
    billing.period = @period
    billing.name  = 'excess_billing'
    billing.title = 'Pré-affectation en excès'
    billing.kind  = 'excess'
    billing.associated_hash = { excess: calculated_excess[:count], price: @package.excess_price  }
    billing.price = calculated_excess[:price] * 100

    billing.save
  end

  def create_orders_billing
    is_manual_paper_set_order = CustomUtils.is_manual_paper_set_order?(@user.organization)
  end

  def create_bank_excess_billing
    if @data_flow.bank_excess > 0
      price   = Package::Pricing.price_of(:bank_excess)

      billing       = Finance::Billing.new
      billing.owner = @user
      billing.period = @period
      billing.name  = 'bank_excess'
      billing.kind  = 'excess'
      billing.title = "#{@data_flow.bank_excess} compte(s) bancaire(s) supplémentaire(s)"
      billing.associated_hash = { excess: @data_flow.bank_excess, price: price  }
      billing.price = price * @data_flow.bank_excess * 100

      billing.save
    end
  end

  def create_journals_excess_billing
    if @data_flow.journals_excess > 0
      price   = Package::Pricing.price_of(:journal_excess)

      billing       = Finance::Billing.new
      billing.owner = @user
      billing.period = @period
      billing.name  = 'journal_excess'
      billing.kind  = 'excess'
      billing.title = "#{@data_flow.journals_excess} journal(aux) comptable(s) supplémentaire(s)"
      billing.associated_hash = { excess: @data_flow.journals_excess, price: price  }
      billing.price =  price * @data_flow.journals_excess * 100

      billing.save
    end
  end

  def create_resit_operations_billing
    operations_periods = @user.operations.where.not(processed_at: nil).where("is_locked = false AND DATE_FORMAT(created_at, '%Y%m') = #{@period}").map{|ope| ope.date.strftime('%Y%m')}.uniq

    operations_periods.each do |_period|
      next if @period <= _period

      title     = "Opérations bancaires mois de #{I18n.l(Date.new(_period.to_s[0..3].to_i, _period.to_s[4..-1].to_i), format: '%B')} #{_period.to_s[0..3].to_i}"
      billing   = @user.billings.of_period(_period).where(name: ['ido_retriever', 'bank_option']).first
      billing ||= @user.billings.of_period(_period).where(name: 'operations_billing', kind: 're-sit', title: title).first

      if not billing
        billing       = Finance::Billing.new
        billing.owner = @user
        billing.period = @period
        billing.name  = 'operations_billing'
        billing.kind  = 're-sit'
        billing.title = title
        billing.price = Package::Pricing.price_of(:ido_retriever) * 100

        billing.save
      end
    end
  end

  def create_digitize_billing
    if @package.name == 'ido_digitize'
      if @data_flow.scanned_sheets > 0
        #### ------- Scanned sheet Option -------- ####
        billing       = Finance::Billing.new
        billing.owner = @user
        billing.period = @period
        billing.name  = 'scanned_sheets'
        billing.title = "#{@data_flow.scanned_sheets} feuille(s) numérisée(s)"
        billing.associated_hash = { excess: @data_flow.scanned_sheets, price: 0.1  }
        billing.price = @data_flow.scanned_sheets * 0.1 * 100

        billing.save

        #### --------- Pack size Option -------- ####
        pack_names = @user.paper_processes.where('DATE_FORMAT(created_at, "%Y%m") = ?', @period).where(type: 'scan').select(:pack_name).distinct
        pack_size  = pack_names.collect(&:pack_name).size

        if pack_size > 0
          billing       = Finance::Billing.new
          billing.owner = @user
          billing.period = @period
          billing.name  = 'scanned_sheets'
          billing.title = "#{pack_size} pochette(s) scannée(s)"
          billing.associated_hash = { excess: pack_size, price: 1  }
          billing.price = pack_size * 100

          billing.save
        end
      end
    end
  end

  def calculated_excess
    return @excess_data if @excess_data.present?

    @excess_data = { price: 0, count: 0 }

    if @package.excess_duration == 'month'
      data_flow = @user.data_flows.where(period: @package.period).select("compta_pieces as t_compta_pieces, compta_operations as t_compta_operations").first
    else
      periods   = @user.packages.where(name: @package.name, version: @package.version).pluck(:period)
      data_flow = @user.data_flows.where(period: periods).select("SUM(compta_pieces) as t_compta_pieces, SUM(compta_operations) as t_compta_operations").first
    end

    @excess_data[:count] = data_flow.try(:t_compta_pieces).to_i + data_flow.try(:t_compta_operations).to_i
    @excess_data[:price] = @package.excess_price * (@excess_data[:count] - @package.flow_limit) if @package.flow_limit > 0 && @excess_data[:count] > @package.flow_limit

    @excess_data
  end
end