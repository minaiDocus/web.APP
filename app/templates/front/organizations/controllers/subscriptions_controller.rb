# frozen_string_literal: true

class Organizations::SubscriptionsController < OrganizationController
  before_action :verify_rights
  before_action :load_subscription

  prepend_view_path('app/templates/front/organizations/views')

  def show
    @subscription_options = @subscription.options.sort_by(&:position)
    @total                = Billing::OrganizationBillingAmount.new(@organization).execute
  end

  # GET /account/organizations/:organization_id/organization_subscription/edit
  def edit
    render partial: 'edit'
  end

  # PUT /account/organizations/:organization_id/organization_subscription
  def update
    if params[:subscription] && @subscription.update(subscription_params)
      Billing::UpdatePeriod.new(@subscription.current_period).execute
      json_flash[:success] = 'Modifié avec succès.'
    else
      json_flash[:error] = "Impossible d'appliquer les modifications"
    end

    render json: { json_flash: json_flash }, status: 200
  end

  # GET /account/organizations/:organization_id/organization_subscription/select_options
  def select_options
    render partial: 'select_options'
  end

  # PUT /account/organizations/:organization_id/organization_subscription/propagate_options
  def propagate_options
    if params[:subscription] && @subscription.update(subscription_quotas_params)
      _params = subscription_quotas_params

      ids = begin
              params[:subscription][:customer_ids] - ['']
            rescue StandardError
              []
            end

      registered_ids = @organization.customers.where(id: ids).pluck(:id)

      if ids.size == registered_ids.size
        subscriptions = Subscription.where(user_id: ids)

        subscriptions.each{|s| s.update(_params) }

        periods = Period.where(subscription_id: subscriptions.map(&:id)).where('start_date <= ? AND end_date >= ?', Date.today, Date.today)

        periods.each do |period|
          period.update(_params)
          Billing::UpdatePeriodPrice.new(period).execute
        end

        json_flash[:success] = 'Propagé avec succès.'
      else
        json_flash[:error] = "Impossible de traiter les informations"
      end
    else
      json_flash[:error] = "Impossible de traiter les informations"
    end

    render json: { json_flash: json_flash }, status: 200
  end

  private

  def verify_rights
    unless @user.is_admin
      flash[:error] = t('authorization.unessessary_rights')

      redirect_to organization_path(@organization)
    end
  end

  def load_subscription
    @subscription = @organization.find_or_create_subscription
  end

  def subscription_params
    params.require(:subscription).permit(option_ids: [])
  end

  def subscription_quotas_params
    _params = params.require(:subscription).permit(
      :max_sheets_authorized,
      :max_upload_pages_authorized,
      :max_dematbox_scan_pages_authorized,
      :max_preseizure_pieces_authorized,
      :max_expense_pieces_authorized,
      :max_paperclips_authorized,
      :max_oversized_authorized,
      :unit_price_of_excess_sheet,
      :unit_price_of_excess_upload,
      :unit_price_of_excess_dematbox_scan,
      :unit_price_of_excess_preseizure,
      :unit_price_of_excess_expense,
      :unit_price_of_excess_paperclips,
      :unit_price_of_excess_oversized
    )

    _params.each { |k, v| _params[k] = v.to_i }
    _params
  end
end
