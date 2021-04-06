# frozen_string_literal: true
class Dashboard::MainController < ApplicationController
  append_view_path('app/templates/front/dashboard/views')

  def index
    a = 1
  end

  def test500
  	render json: { success: false }, status: 500
  end
end