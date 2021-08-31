# frozen_string_literal: true
class RetrievedDatas::MainController < RetrieverController
  before_action :verif_account
  prepend_view_path('app/templates/front/retrieved_datas/views')

  def index;  end
end