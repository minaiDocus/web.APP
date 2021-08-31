# frozen_string_literal: true

class Reporting::MainController < FrontController
  before_action :load_organization
  before_action :load_params, except: %w(show)
  prepend_view_path('app/templates/front/reporting/views')

  def injected_documents
    respond_to do |format|
      format.html do
        @packs = Pack.where("created_at BETWEEN '#{@date_range.join("' AND '")}'").where(owner_id: @customers_ids).order(updated_at: :asc).limit(10)

        render partial: 'lastest_sending_docs'
      end
      format.json do
        range_date   = []
        pieces_count = []

        7.times.reverse_each do |i|
          date = i.days.ago
          range_date << date.strftime("%d/%m")

          pieces_count << Pack::Piece.where(user_id: @customers_ids).where("DATE_FORMAT(created_at, '%d%m%Y') = '#{date.strftime("%d%m%Y")}'").count
        end

        
        render json: { range_date: range_date, pieces_count: pieces_count, max_count: pieces_count.max, min_count: pieces_count.min }, state: 200
      end
    end
  end

  def pre_assignment_accounts
    respond_to do |format|
      format.html do
        @reports = Pack::Report.where("created_at BETWEEN '#{@date_range.join("' AND '")}'").where(user_id: @customers_ids).order(updated_at: :asc).limit(10)

        render partial: 'pre_assignment_accounts'
      end
      format.json do
        anomaly_accounts = AccountBookType.where(user_id: @customers_ids).distinct.select(:anomaly_account).collect(&:anomaly_account).compact
        waiting_accounts = AccountBookType.where(user_id: @customers_ids).distinct.select(:account_number).collect(&:account_number).compact
        default_accounts = AccountBookType.where(user_id: @customers_ids).distinct.select(:default_account_number).collect(&:default_account_number).compact

        preseizures_ids  = Pack::Report::Preseizure.where("created_at BETWEEN '#{@date_range.join("' AND '")}'").where(user_id: @customers_ids).select(:id)

        all_accounts_size     = Pack::Report::Preseizure::Account.where(preseizure_id: preseizures_ids).count
        anomaly_accounts_size = Pack::Report::Preseizure::Account.where(preseizure_id: preseizures_ids, number: anomaly_accounts).count
        waiting_accounts_size = Pack::Report::Preseizure::Account.where(preseizure_id: preseizures_ids, number: waiting_accounts).count
        default_accounts_size = Pack::Report::Preseizure::Account.where(preseizure_id: preseizures_ids, number: default_accounts).count
        normal_accounts_size  = all_accounts_size - anomaly_accounts_size - waiting_accounts_size - default_accounts_size

        render json: { labels: ['Compte normale', 'Compte anomalie', 'Compte par défaut', "Compte d'attente"], counts: [normal_accounts_size, anomaly_accounts_size, default_accounts_size, waiting_accounts_size] }, state: 200
      end
    end
  end

  def retrievers_report
    @retrievers = Retriever.where("created_at BETWEEN '#{@date_range.join("' AND '")}'").where(user_id: @customers_ids)

    respond_to do |format|
        format.html do
          @retrievers = @retrievers.where(state: 'error')

          render partial: 'failed_retrievers'
        end
        format.json do
          retrievers = @retrievers.count
          retrievers_error = @retrievers.where(state: 'error').count
          retrievers_error_percentage = (retrievers > 0) ? ((retrievers_error * 100) / retrievers).ceil : 0

          render json:{ actif_percentage: ((retrievers > 0) ? (100 - retrievers_error_percentage) : 0), error_percentage: retrievers_error_percentage }, state: 200
        end
    end
  end

  def show
  end

  def backup_show
    @year = begin
              Integer(params[:year])
            rescue StandardError
              Time.now.year
            end

    date = Date.parse("#{@year}-01-01")
    periods = Period.includes(:billings, :user, :subscription).where(user_id: account_ids)
                    .where('start_date >= ? AND end_date <= ?', date, date.end_of_year)
                    .order(start_date: :asc)
    @periods_by_users = periods.group_by { |period| period.user.id }.each do |_user, periods|
      periods.sort_by!(&:start_date)
    end

    respond_to do |format|
      format.html
      format.xls do
        data = Subscription::PeriodsToXls.new(periods).execute
        send_data data, type: 'application/vnd.ms-excel', filename: "reporting_iDocus_#{@year}.xls"
      end
    end
  end

  private

  def load_organization
    @organization  ||= (params[:organization_id])? Organization.where(id: params[:organization_id]).first : nil
  end

  def load_params
    @customers_ids = (@organization)? @organization.customers.where(id: account_ids).collect(&:id) : account_ids
    # @date_range    = CustomUtils.parse_date_range_of(params[:date_range])
    @date_range    = ['2021-07-01 00:00:00', '2021-08-01 23:59:59'] #For test

    if params[:ids].present? && params[:ids] != "null"
      if params[:ids].is_a?(Array)
        @customers_ids = params[:ids]
      else
        @customers_ids = params[:ids].split(',')
      end
    end
  end
end