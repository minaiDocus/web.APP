# frozen_string_literal: true
class OrganizationController < ApplicationController
  include ConfigurationSteps

  before_action :is_organization_layout
  before_action :login_user!
  before_action :load_user_and_role
  before_action :verify_if_active
  before_action :verify_suspension
  before_action :verify_if_a_collaborator
  before_action :load_organization
  before_action :apply_membership
  before_action :load_recent_notifications

  layout('front/layout') # TODO ..

  protected

  def is_organization_layout
    @is_organization_layout = true
  end

  def verify_if_a_collaborator
    unless @user.collaborator?
      redirect_to root_path, flash: { error: t('authorization.unessessary_rights') }
    end
  end

  def organization_id
    @organization_id ||= (params[:controller] == 'organizations/main' && controller_name == 'main') ? params[:id] : params[:organization_id]
  end

  def load_organization
    if @user.admin?
      @organization = ::Organization.find organization_id
    elsif organization_id.present?
      @membership = Member.find_by!(user_id: @user.id, organization_id: organization_id.to_i)
      @organization = @membership.organization
    else
      redirect_to root_path, flash: { error: t('authorization.unessessary_rights') }
    end
  end

  def apply_membership
    @user.with_scope @membership, @organization
  end

  def customers
    @user.customers
  end
  helper_method :customers

  def customer_ids
    customers.map(&:id)
  end

  def load_customer
    @customer = customers.find params[:customer_id]
  end

  def multi_organizations?
    @organization.belongs_to_groups?
  end
  helper_method :multi_organizations?
end