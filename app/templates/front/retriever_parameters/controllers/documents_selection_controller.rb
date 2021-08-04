# frozen_string_literal: true
class RetrieverParameters::DocumentsSelectionController < RetrieverController
  append_view_path('app/templates/front/retriever_parameters/views')

  def index
    @documents = TempDocument.search_for_collection(
                                @account.temp_documents.retrieved.joins(:metadata2), search_terms(params[:document_contains])
                              )
                             .wait_selection
                             .includes(:retriever, :piece)
                             .order(order_param)
                             .page(params[:page])
                             .per(params[:per_page])

    if params[:document_contains].try(:[], :retriever_id).present?
      @retriever = @account.retrievers.find(params[:document_contains][:retriever_id])
      @retriever.ready if @retriever.waiting_selection?
    end

    render partial: 'documents_selection', locals: { documents: @documents }
  end

  private

  def sort_column
    if params[:sort].in? %w[created_at retriever_id date name pages_number amount]
      params[:sort]
    else
      'created_at'
    end
  end
  helper_method :sort_column

  def sort_direction
    if params[:direction].in? %w[asc desc]
      params[:direction]
    else
      'desc'
    end
  end
  helper_method :sort_direction

  def order_param
    if sort_column.in?(%w[date name amount])
      "temp_document_metadata.#{sort_column} #{sort_direction}"
    else
      { sort_column => sort_direction }
    end
  end
end