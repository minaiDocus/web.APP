class TemplatesController < ApplicationController
  XHR_TOKEN = 'dHkgbnkgdG9rZW4gYW5sZSBhamF4'
  before_action :check_xhr_token

  def check_xhr_token
    xhr_token = params[:xhr_token].to_s
    path      = request.path.to_s

    if xhr_token != TemplatesController::XHR_TOKEN && path != '/'
      next_path = Base64.encode64 path
      redirect_to "#{root_path}?r=#{next_path}"
    end
  end
end