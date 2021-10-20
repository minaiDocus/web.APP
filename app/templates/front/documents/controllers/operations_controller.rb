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
    options[:by_preseizure] = params[:by_preseizure]

    if !params[:by_all].present? && !params[:by_preseizure].present?      
      options = session[:params_document_operation] if session[:params_document_operation].present? && !params[:reinit].present?
      session.delete(:params_document_operation)    if params[:reinit].present?            
    end

    options[:user_ids] = if params[:view].present? && params[:view] != 'all'
                        params[:view].split(',')
                      elsif session[:params_document_operation].try(:[], :user_ids).present?
                        session[:params_document_operation][:user_ids]               
                      else
                        account_ids
                      end

    options[:journal] =   if params[:journal].present? 
                            params[:journal].split(',')
                          elsif session[:params_document_operation].try(:[], :journal).present?
                            session[:params_document_operation][:journal]
                          else
                            []
                          end

    if options[:by_preseizure].present? && (options[:by_preseizure].try(:[], 'is_delivered') != "" || options[:by_preseizure].try(:[], 'third_party') != "" || options[:by_preseizure].try(:[], 'delivery_tried_at') != "" || options[:by_preseizure].try(:[], 'date') != "" || options[:by_preseizure].try(:[], 'amount') != '')
      reports_ids = Pack::Report::Preseizure.where(user_id: options[:user_ids]).where('operation_id > 0').filter_by(options[:by_preseizure]).distinct.pluck(:report_id).presence || [0]      
    end

    options[:ids] = reports_ids if reports_ids.present?    
 
    session[:params_document_operation] = options.dup.reject{ |k,v| k == :ids } unless params[:reinit].present?
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