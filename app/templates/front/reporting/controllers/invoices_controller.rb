# frozen_string_literal: true

class Reporting::InvoicesController < Reporting::ABaseController
  skip_before_action :load_report_organization, only: %w(period)
  skip_before_action :load_params, only: %w(period)

  before_action :load_period, :verify_rights, only: %w(period)

  prepend_view_path('app/templates/front/reporting/views')

  def period
    render json: PeriodPresenter.new(@period, current_user).render_json, status: 200
  end

  def index0
    @year = begin
              Integer(params[:year])
            rescue StandardError
              Time.now.year
            end

    date = Date.parse("#{@year}-01-01")
    periods = Period.includes(:billings, :user, :subscription).where(user_id: @customers_ids)
                    .where('start_date >= ? AND end_date <= ?', date, date.end_of_year)
                    .order(start_date: :asc)
    @periods_by_users = periods.group_by { |period| period.user.id }.each do |_user, periods|
      periods.sort_by!(&:start_date)
    end

    respond_to do |format|
      format.html do
        render partial: 'index'
      end
      format.xls do
        data = Subscription::PeriodsToXls.new(periods).execute
        send_data data, type: 'application/vnd.ms-excel', filename: "reporting_iDocus_#{@year}.xls"
      end
    end
  end

  def index
    #User, BillingMod::Billing => app\mods\billing\models\billing.rb, BillingMod::DataFlow => data_flow.rb, BillingMod::Package => package.rb
    render partial: 'index'
    puts "current user = #{current_user.name}"
    puts "current user's first name = #{current_user.first_name}"
    puts "current user's last name = #{current_user.last_name}"
    puts "current user's id = #{current_user.id}"

  end

  private

  def load_period
    @period = Period.find(params[:id])
  end

  def verify_rights
    unless @period.user.in?(accounts)
      json_flash[:error] = 'Action non autorisée'
      render json: { json_flash: json_flash }, status: 200
    end
  end


end