# frozen_string_literal: true
module Dashbord
  class IndexController < ApplicationController
    before_action :login_user!
    before_action :load_user_and_role
    before_action :verify_suspension
    before_action :verify_if_active

    def index
      
    end
  end
end
