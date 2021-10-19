# frozen_string_literal: true

class Documents::OperationsController < FrontController
  skip_before_action :verify_if_active, only: %w[index show]
  prepend_view_path('app/templates/front/documents/views')

  before_action :set_is_operation
  before_action :load_report, except: %w[index]

  # GET /operations
  def index
  	@reports = Pack::Report.where(pack_id: [nil, '']).search(options).distinct.order(updated_at: :desc).page(options[:page]).per(options[:per_page])
  end

  # GET /operations/:id
  def show
    preseizures = @report.preseizures.where('operation_id > 0')

    preseizures = preseizures.filter_by(options)

    if options[:name].present?
      preseizures = preseizures.joins(:operation).where("operations.label LIKE '%#{params[:text]}%'")
    end

    @preseizures = preseizures.distinct.order(updated_at: :asc).page(options[:page]).per(10)
  end

  private

  def options
    options = { page: params[:page], per_page: 14 } #IMPORTANT: per_page option must be a multiple of 4 and > 8 (needed by grid type view)
    options[:sort] = true

    if params[:by_all].present?
      params[:by_piece] = params[:by_piece].present? ? params[:by_piece].merge(params[:by_all].permit!) : params[:by_all]
    end

    options[:position] = params[:by_piece].try(:[], :position)
    options[:position_operation] = params[:by_piece].try(:[], :position_operation)

    options[:name] = params[:text]

    options[:pre_assignment_is_delivered] = params[:by_preseizure].try(:[], 'is_delivered')
    
    options[:delivery_tried_at] = params[:by_preseizure].try(:[], 'delivery_tried_at')
    options[:date] = params[:by_preseizure].try(:[], 'date')    

    options[:third_party] = params[:by_preseizure].try(:[], 'third_party')
    options[:piece_number] = params[:by_preseizure].try(:[], 'piece_number')

    options[:amount] = params[:by_preseizure].try(:[], 'amount')
    options[:amount_operation] = params[:by_preseizure].try(:[], 'amount_operation')

    options[:user_ids] = if params[:view].present? && params[:view] != 'all'
                            params[:view].split(',')   
                          else
                            account_ids
                          end

    if params[:by_preseizure].present? && (params[:by_preseizure].try(:[], 'is_delivered') != "" || params[:by_preseizure].try(:[], 'third_party') != "" || params[:by_preseizure].try(:[], 'delivery_tried_at') != "" || params[:by_preseizure].try(:[], 'date') != "" || params[:by_preseizure].try(:[], 'amount') != '')
      reports_ids = Pack::Report::Preseizure.where(user_id: options[:user_ids]).where('operation_id > 0').filter_by(params[:by_preseizure]).distinct.pluck(:report_id).presence || [0]      
    end

    options[:ids] = reports_ids if reports_ids.present?
     
    if not params[:by_all].present?
      options = session[:params_document_operation] if session[:params_document_operation].present? && !params[:reinit].present?
      session.delete(:params_document_operation) if params[:reinit].present?
    else
      session.delete(:params_document_operation)
      session[:params_document_operation] = options
    end

    options
  end

  def load_report
  	@report = Pack::Report.where(id: params[:id], pack_id: [nil, '']).first
    # @report = nil if not account_ids.include? @report.user_id #disable temporarly to be enable later
    options

    redirect_to operations_path if not @report
  end

  def set_is_operation
    @is_operations = true
  end
end