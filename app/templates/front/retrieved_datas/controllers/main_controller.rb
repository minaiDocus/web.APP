# frozen_string_literal: true
class RetrievedDatas::MainController < RetrieverController
  before_action :verif_account
  append_view_path('app/templates/front/retrieved_datas/views')

  def index;  end
end