# frozen_string_literal: true
class RetrieverParameters::MainController < RetrieverController
  before_action :verif_account
  append_view_path('app/templates/front/retriever_parameters/views')

  def index;  end
end