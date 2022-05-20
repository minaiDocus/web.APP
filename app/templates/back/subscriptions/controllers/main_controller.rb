# frozen_string_literal: true
class Admin::Subscriptions::MainController < BackController
  prepend_view_path('app/templates/back/subscriptions/views')

  before_action :load_accounts_ids
  # GET /admin/subscriptions
  def index
    new_subscription_count

    params[:per_page] ||= 50
    statistics = order(StatisticsManager.get_compared_subscription_statistics(statistic_params))

    @organization_count = statistics.size
    @statistics = Kaminari.paginate_array(statistics).page(params[:page]).per(params[:per_page])
    @statistics_total = calculate_total_of statistics

    respond_to do |format|
      format.html
      format.xls do
        filename = "Reporting_forfaits_iDocus_#{I18n.l(statistic_params[:first_period], format: '%b%y').titleize}_#{I18n.l(statistic_params[:second_period], format: '%b%y').titleize}.xls"
        send_data Subscription::StatisticsToXls.new(statistics).execute, type: 'application/vnd.ms-excel', filename: filename
      end
    end
  end  

  def accounts
    render partial: 'accounts', layout: false, locals: { data_accounts: new_data_accounts }
  end

  private

  def load_accounts_ids
    @accounts_ids = []
    Organization.billed.each do |org|
      @accounts_ids += org.customers.active_at(Time.now.end_of_month).pluck(:id)
    end
    @accounts_ids.flatten!
  end

  def statistic_params
    options = { organization: params[:organization] }
    options[:first_period]  = (params[:first_period].present? ? params[:first_period].to_date : 1.month.ago)
    options[:second_period] = (params[:second_period].present? ? params[:second_period].to_date : Date.today)
  rescue StandardError
    options[:first_period]  = 1.month.ago.to_date
    options[:second_period] = Date.today
  ensure
    return options
  end

  def calculate_total_of(statistics)
    {
      basic_package: statistics.inject(0) { |sum, s| sum + s.options[:basic_package].to_i },
      basic_package_diff: statistics.inject(0) { |sum, s| sum + s.options[:basic_package_diff].to_i },
      mail_package: statistics.inject(0) { |sum, s| sum + s.options[:mail_package].to_i },
      mail_package_diff: statistics.inject(0) { |sum, s| sum + s.options[:mail_package_diff].to_i },
      scan_box_package: statistics.inject(0) { |sum, s| sum + s.options[:scan_box_package].to_i },
      scan_box_package_diff: statistics.inject(0) { |sum, s| sum + s.options[:scan_box_package_diff].to_i },
      retriever_package: statistics.inject(0) { |sum, s| sum + s.options[:retriever_package].to_i },
      retriever_package_diff: statistics.inject(0) { |sum, s| sum + s.options[:retriever_package_diff].to_i },
      digitize_package: statistics.inject(0) { |sum, s| sum + s.options[:digitize_package].to_i },
      digitize_package_diff: statistics.inject(0) { |sum, s| sum + s.options[:digitize_package_diff].to_i },
      mini_package: statistics.inject(0) { |sum, s| sum + s.options[:mini_package].to_i },
      mini_package_diff: statistics.inject(0) { |sum, s| sum + s.options[:mini_package_diff].to_i },
      micro_package: statistics.inject(0) { |sum, s| sum + s.options[:micro_package].to_i },
      micro_package_diff: statistics.inject(0) { |sum, s| sum + s.options[:micro_package_diff].to_i },
      nano_package: statistics.inject(0) { |sum, s| sum + s.options[:nano_package].to_i },
      nano_package_diff: statistics.inject(0) { |sum, s| sum + s.options[:nano_package_diff].to_i },
      idox_package: statistics.inject(0) { |sum, s| sum + s.options[:idox_package].to_i },
      idox_package_diff: statistics.inject(0) { |sum, s| sum + s.options[:idox_package_diff].to_i },
      premium_package: statistics.inject(0) { |sum, s| sum + s.options[:premium_package].to_i },
      premium_package_diff: statistics.inject(0) { |sum, s| sum + s.options[:premium_package_diff].to_i },
      annual_package: statistics.inject(0) { |sum, s| sum + s.options[:annual_package].to_i },
      annual_package_diff: statistics.inject(0) { |sum, s| sum + s.options[:annual_package_diff].to_i },
      upload: statistics.inject(0) { |sum, s| sum + s.consumption[:upload].to_i },
      scan: statistics.inject(0) { |sum, s| sum + s.consumption[:scan].to_i },
      dematbox_scan: statistics.inject(0) { |sum, s| sum + s.consumption[:dematbox_scan].to_i },
      retriever: statistics.inject(0) { |sum, s| sum + s.consumption[:retriever].to_i },
      customers: statistics.inject(0) { |sum, s| sum + s.customers&.size.to_i },
      new_customers: statistics.inject(0) { |sum, s| sum + s.try(:new_customers)&.size.to_i },
      closed_customers: statistics.inject(0) { |sum, s| sum + s.try(:closed_customers)&.size.to_i }
    }
  end

  def sort_column
    params[:sort] || 'organization_name'
  end
  helper_method :sort_column

  def sort_direction
    params[:direction] || 'asc'
  end
  helper_method :sort_direction

  def order(statistics)
    attribute = sort_column.to_s.split('.')[0]
    h_value = sort_column.to_s.split('.')[1] || nil
    if h_value.nil?
      if attribute == 'customers' || attribute == 'new_customers' || attribute == 'closed_customers'
        result = statistics.sort { |a, b| a.send(attribute)&.size.to_i <=> b.send(attribute)&.size.to_i }
      else
        result = statistics.sort { |a, b| a.send(attribute) <=> b.send(attribute) }
      end
    else
      result = statistics.sort { |a, b| a.send(attribute)[h_value.to_sym] <=> b.send(attribute)[h_value.to_sym] }
    end

    sort_direction == 'desc' ? result.reverse! : result
  end

  def new_subscription_count
    @mail_package_count = @basic_package_count = @pre_assignment_count = @annual_package_count = @scan_box_package_count = @retriever_package_count = @digitize_package_count = @mini_package_count = @micro_package_count = @nano_package_count = @idox_package_count = @retriever_only_package_count = @digitize_only_package_count = @ido_premium = @not_configured = 0

    BillingMod::Package.of_period(CustomUtils.period_of(Time.now)).each do |package|
      next if not @accounts_ids.include?(package.user_id)
      case package.name
        when 'ido_classic'
          @basic_package_count += 1
        when 'ido_nano'
          @nano_package_count += 1
        when 'ido_x'
          @idox_package_count += 1
        when 'ido_micro' || 'ido_micro_plus'
          @micro_package_count += 1
        when 'ido_retriever'
          @retriever_only_package_count += 1
        when 'ido_digitize'
          @digitize_only_package_count += 1
        end

        @mail_package_count += 1      if package.mail_active
        @pre_assignment_count += 1    if package.preassignment_active
        @retriever_package_count += 1 if package.bank_active && package.name != 'ido_retriever'
        @digitize_package_count += 1  if package.scan_active && CustomUtils.is_manual_paper_set_order?(package.try(:user).try(:organization)) && package.name != 'ido_digitize'
        @not_configured += 1          if package.name == ""
    end
  end

  def new_data_accounts
    package = BillingMod::Package.of_period(CustomUtils.period_of(Time.now))


    case params[:type]
    when 'mail_package'
      data_accounts = Rails.cache.fetch('admin_report_mail_package_accounts', expires_in: 10.minutes) { package.where(mail_active: true) }
    when 'basic_package'
      data_accounts = Rails.cache.fetch('admin_report_basic_package_accounts', expires_in: 10.minutes) { package.where(name: 'ido_classic') }
    when 'annual_package'
      data_accounts = Rails.cache.fetch('admin_report_annual_package_accounts', expires_in: 10.minutes) { package.where(name: 'ido_annual') }
    when 'pre_assignment_active'
      data_accounts = Rails.cache.fetch('admin_report_pre_assignment_accounts', expires_in: 10.minutes) { package.where(preassignment_active: true) }
    when 'scan_box_package'
      data_accounts = Rails.cache.fetch('admin_report_scan_box_package_accounts', expires_in: 10.minutes) { package.where(scan_active: true) }
    when 'retriever_package'
      data_accounts = Rails.cache.fetch('admin_report_retriever_package_accounts', expires_in: 10.minutes) { package.where(bank_active: true)  }
    when 'digitize_package'
      data_accounts = Rails.cache.fetch('admin_report_digitize_package_accounts', expires_in: 10.minutes) { package.where(scan_active: true) }
    when 'mini_package'
      data_accounts = Rails.cache.fetch('admin_report_mini_package_accounts', expires_in: 10.minutes) { package.where(name: 'ido_mini') }
    when 'premium_package'
      data_accounts = Rails.cache.fetch('admin_report_mini_package_accounts', expires_in: 10.minutes) { package.where(name: 'ido_premium') }
    when 'micro_package'
      data_accounts = Rails.cache.fetch('admin_report_micro_package_accounts', expires_in: 10.minutes) { package.where(name: ['ido_micro', 'ido_micro_plus']) }
    when 'nano_package'
      data_accounts = Rails.cache.fetch('admin_report_nano_package_accounts', expires_in: 10.minutes) { package.where(name: 'ido_nano') }
    when 'idox_package'
      data_accounts = Rails.cache.fetch('admin_report_idox_package_accounts', expires_in: 10.minutes) { package.where(name: 'ido_x') }
    when 'retriever_only_package'
      data_accounts = Rails.cache.fetch('admin_report_retriever_only_package_accounts', expires_in: 10.minutes) { package.where(name: 'ido_retriever') }
    when 'digitize_only_package'
      data_accounts = Rails.cache.fetch('admin_report_digitize_only_package_accounts', expires_in: 10.minutes) { package.where(name: 'ido_digitize') }
    when 'not_configured'
      data_accounts = Rails.cache.fetch('admin_report_not_configured_accounts', expires_in: 10.minutes) { package.where(name: [nil, '']) }
    else
      data_accounts = []
    end

    _data_accounts = data_accounts.try(:any?) ? data_accounts.collect(&:user_id) : []

    _account_ids = @accounts_ids & _data_accounts

    User.where(id: _account_ids, inactive_at: nil)
  end
end