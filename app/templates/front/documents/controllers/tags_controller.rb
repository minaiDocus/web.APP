# frozen_string_literal: true
class Documents::TagsController < FrontController
  layout(nil)

  before_action :load_model
  append_view_path('app/templates/front/documents/views')

  def index
    @model
  end

  def update_multiple
    UpdateMultipleTags.execute(@user, params[:tags], params[:document_ids], params[:type])

    respond_to do |format|
      format.json { render json: {}, status: :ok }
      format.html { redirect_to root_path }
    end
  end

  def get_tag_content
    @documents = params[:type_tag] == 'piece' ? Pack::Piece.where(id: params[:ids]) : Document.where(id: params[:ids])

    render partial: 'documents/main/pieces/tag_dialog'
  end

  private

  def load_model
    if params[:type] == 'pack'
      @model = Pack.find params[:id]
    else
      @model = Pack::Piece.find params[:id]
    end
  end
end
