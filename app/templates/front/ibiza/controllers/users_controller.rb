# frozen_string_literal: true

class Ibiza::UsersController < OrganizationController
  before_action :load_ibiza
  before_action :verify_rights

  append_view_path('app/templates/front/ibiza/views')

  # GET /account/organizations/:organization_id/ibiza_users
  def index
    users = Rails.cache.read([:ibiza, @ibiza.id, :users])

    unless users
      @ibiza.get_users
      users = Rails.cache.read([:ibiza, @ibiza.id, :users])
    end

    result = if users
               users.map do |user|
                 { name: user.name, id: user.id }
               end
             else
               []
             end

    respond_to do |format|
      format.json { render json: result }
    end
  end

  private

  def verify_rights
    unless @ibiza.try(:configured?)
      flash[:error] = t('authorization.unessessary_rights')
      redirect_to organization_path(@organization)
    end
  end

  def load_ibiza
    @ibiza = @organization.ibiza
  end
end
