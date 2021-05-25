# frozen_string_literal: true
class PreAssignments::MainController < OrganizationController
  append_view_path('app/templates/front/pre_assignments/views')

  
  # GET /organizations/:organization_id/pre_assignments
  def index
    @ibiza = @organization.ibiza
  end
end