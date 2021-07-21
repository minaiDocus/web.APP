# frozen_string_literal: true

class Documents::OperationsController < FrontController
  append_view_path('app/templates/front/documents/views')

  before_action :set_is_operation
  before_action :load_report, except: %w[index]

  # GET /operations
  def index
    options = { page: params[:page], per_page: 14 }

    options[:name] = params[:text]

    options[:user_ids] = if params[:view].present? && params[:view] != 'all'
                            _user = accounts.find(params[:view])
                            _user ? [_user.id] : []
                          else
                            account_ids
                          end

    if params[:by_preseizure].present? && (params[:by_preseizure].try(:[], 'is_delivered').present? || params[:by_preseizure].try(:[], 'delivery_tried_at').present? || params[:by_preseizure].try(:[], 'date').present? || params[:by_preseizure].try(:[], 'amount').present?)
      reports_ids = Pack::Report::Preseizure.where(user_id: options[:user_ids]).where('operation_id > 0').filter_by(params[:by_preseizure]).distinct.pluck(:report_id).presence || [0]
    end
    options[:ids] = reports_ids if reports_ids.present?

  	@reports = Pack::Report.where(pack_id: [nil, '']).search(options).distinct.order(updated_at: :desc).page(options[:page]).per(options[:per_page])
  end

  # GET /operations/:id
  def show
    preseizures = @report.preseizures

    if params[:by_preseizure].present? && (params[:by_preseizure].try(:[], 'is_delivered').present? || params[:by_preseizure].try(:[], 'delivery_tried_at').present? || params[:by_preseizure].try(:[], 'date').present? || params[:by_preseizure].try(:[], 'amount').present?)
      preseizures = preseizures.filter_by(params[:by_preseizure])
    end

    if params[:text].present?
      preseizures = preseizures.joins(:operation).where("operations.label LIKE '%#{params[:text]}%'")
    end

    @preseizures = preseizures.distinct.order(updated_at: :asc).page(params[:page]).per(10)
  end

  private

  def load_report
  	@report = Pack::Report.where(id: params[:id]).first
    # @report = nil if not account_ids.include? @report.user_id #disable temporarly to be enable later

    redirect_to operations_path if not @report
  end

  def set_is_operation
    @is_operations = true
  end
end