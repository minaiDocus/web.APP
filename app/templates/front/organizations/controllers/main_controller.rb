# frozen_string_literal: true

class Organizations::MainController < OrganizationController
  layout :layout_by_action

  before_action :verify_suspension, only: %w[show edit update]
  before_action :load_organization, except: %w[index edit_options update_options new create]
  before_action :apply_membership
  before_action :verify_rights

  prepend_view_path('app/templates/front/organizations/views')

  # GET /account/organizations/:id/update_options
  def edit_options; end

  # PUT /account/organizations/:id/update_options
  def update_options
    Settings.first.update(is_journals_modification_authorized: params[:settings][:is_journals_modification_authorized] == '1')
    flash[:success] = 'Modifié avec succès.'
    redirect_to account_organizations_path
  end

  # GET /account/organizations/:id/
  def show
    @organization_statistic = SubscriptionStatistic.where(organization_id: @organization.id).first
    @stat_customers_labels = []
    @stat_customers_values = []

    date = Time.now.beginning_of_month
    6.times do |i|
      date = date - 1.month

      @stat_customers_labels << date.strftime('%m/%Y')
      @stat_customers_values << @organization.customers.active.where("DATE_FORMAT(created_at, '%Y%m') <= #{date.strftime('%Y%m')}").size
    end
    # @members = @organization.customers.page(params[:page]).per(params[:per])
    # @periods = Period.where(user_id: @organization.customers.pluck(:id)).where('start_date < ? AND end_date > ?', Date.today, Date.today).includes(:billings)
  end

  # GET /account/organizations/:id/edit
  def edit; end

  # PUT /account/organizations/:id
  def update
    if params[:part].present? && organization_params["#{params[:part]}_attributes"].present?
      case params[:part]
      when 'my_unisoft'
        is_used         = organization_params['my_unisoft_attributes']['is_used'] == "1"
        auto_deliver    = organization_params['my_unisoft_attributes']['auto_deliver']

        result = MyUnisoftLib::Setup.new({organization: @organization, columns: {is_used: is_used, auto_deliver: auto_deliver}}).execute 
      else
        is_used         = organization_params["#{params[:part]}_attributes"]['is_used'] == "1"
        auto_deliver    = organization_params["#{params[:part]}_attributes"]['auto_deliver']
        result = Software::UpdateOrCreate.assign_or_new({owner: @organization, columns: {is_used: is_used, auto_deliver: auto_deliver}, software: params[:part]})
      end

      if result
        json_flash[:success] = 'Modifié avec succès.'
      else
        json_flash[:error] = 'Erreur de mise à jour.'
      end
    elsif @organization.update(organization_params)
      json_flash[:success] = 'Modifié avec succès.'
    else
      json_flash[:error] = 'Erreur de mise à jour.'
    end

    render json: { json_flash: json_flash }, status: 200
  end

  # PUT /account/organizations/:id/activate
  def activate
    @organization.update_attribute(:is_active, true)
    flash[:success] = 'Activé avec succès.'
    redirect_to organization_path(@organization)
  end

  # PUT /account/organizations/:id/deactivate
  def deactivate
    Organization::Deactivate.new(@organization.id.to_s).execute
    @organization.update_attribute(:is_active, false)
    flash[:success] = 'Désactivé avec succès.'
    redirect_to organization_path(@organization)
  end

  # GET /account/organizations/:id/close_confirm
  def close_confirm; end

  # GET /account/organizations/:id/edit_payment
  def edit_payment; end

  def prepare_payment
    debit_mandate = @organization.debit_mandate

    if debit_mandate.pending?
      debit_mandate.title             = payment_params[:gender]
      debit_mandate.firstName         = payment_params[:first_name]
      debit_mandate.lastName          = payment_params[:last_name]
      debit_mandate.email             = payment_params[:email]
      debit_mandate.invoiceLine1      = payment_params[:address]
      debit_mandate.invoiceLine2      = payment_params[:address_2]
      debit_mandate.invoiceCity       = payment_params[:city]
      debit_mandate.invoicePostalCode = payment_params[:postal_code]
      debit_mandate.invoiceCountry    = payment_params[:country]
    end

    if debit_mandate.save
      mandate = Billing::DebitMandateResponse.new debit_mandate
      mandate.prepare_order

      if mandate.errors
        render json: { success: false, message: mandate.errors }, status: 200
      else
        debit_mandate.update(reference: mandate.order_reference, transactionStatus: 'started')

        render json: { success: true, frame_64: mandate.get_frame }, status: 200
      end
    else
      render json: { success: false, message: debit_mandate.errors.message }, status: 200
    end
  end

  def confirm_payment
    debit_mandate = @organization.debit_mandate
    if debit_mandate.started?
      Billing::DebitMandateResponse.new(debit_mandate).confirm_payment
    end

    render json: { success: true, debit_mandate: @organization.debit_mandate.reload }, status: 200
  end

  def revoke_payment
    if @user.is_admin && params[:revoke_confirm] == 'true'
      result = Billing::DebitMandateResponse.new(@organization.debit_mandate).send(:revoke_payment)
      if result.present?
        json_flash[:error]   = result
      else
        json_flash[:success] = 'Mandat supprimé avec succès.'
      end
    end

    render json: { json_flash: json_flash }, status: 200
  end

  private

  def verify_rights
    unless @user.is_admin
      authorized = false
      if current_user.is_admin && action_name.in?(%w[index edit_options update_options edit_software_users update_software_users new create prepare_payment confirm_payment suspend unsuspend])
        authorized = true
      elsif action_name.in?(%w[show]) && @user.is_prescriber
        authorized = true
      elsif action_name.in?(%w[edit update edit_software_users update_software_users prepare_payment confirm_payment]) && @user.leader?
        authorized = true
      end

      unless authorized
        flash[:error] = t('authorization.unessessary_rights')
        redirect_to root_path
      end
    end
  end

  def layout_by_action
    if action_name.in?(%w[index edit_options update_options new create])
      'front/layout'
    else
      'front/layout' # TODO ....
    end
  end

  def organization_params
    if @user.is_admin
      params.require(:organization).permit(
        :name,
        :code,
        :is_detail_authorized,
        :is_test,
        :is_pre_assignment_date_computed,
        :is_operation_processing_forced,
        :is_operation_value_date_needed,
        :is_duplicate_blocker_activated,
        :preseizure_date_option,
        :subject_to_vat,
        :invoice_mails,
        :jefacture_api_key,
        :specific_mission,
        :default_banking_provider,
        { :quadratus_attributes => %i[id is_used auto_deliver] },
        { :coala_attributes => %i[id is_used auto_deliver] },
        { :cegid_attributes => %i[id is_used auto_deliver] },
        { :fec_agiris_attributes => %i[id is_used auto_deliver] },
        { :csv_descriptor_attributes => %i[id is_used auto_deliver] },
        { :exact_online_attributes => %i[id is_used auto_deliver] },
        { :my_unisoft_attributes => %i[id is_used auto_deliver] }
      )
    else
      params.require(:organization).permit(
        :name,
        :authd_prev_period,
        :auth_prev_period_until_day,
        :is_pre_assignment_date_computed,
        :is_operation_processing_forced,
        :is_operation_value_date_needed,
        :is_duplicate_blocker_activated,
        :preseizure_date_option,
        :invoice_mails,
        :jefacture_api_key,
        { :quadratus_attributes => %i[id is_used auto_deliver] },
        { :coala_attributes => %i[id is_used auto_deliver] },
        { :cegid_attributes => %i[id is_used auto_deliver] },
        { :fec_agiris_attributes => %i[id is_used auto_deliver] },
        { :csv_descriptor_attributes => %i[id is_used auto_deliver] },
        { :exact_online_attributes => %i[id is_used auto_deliver] },
        { :my_unisoft_attributes => %i[id is_used auto_deliver] }
      )
    end
  end

  def payment_params
    params.permit(
      :gender,
      :first_name,
      :last_name,
      :email,
      :phone_number,
      :address,
      :address_2,
      :city,
      :postal_code,
      :country
    )
  end

  def to_redirect
    if params[:part].present?
      redirect_to organization_path(@organization, tab: params[:part])
    else
      redirect_to organization_path(@organization)
    end
  end

  def sort_column
    params[:sort] || 'name'
  end
  helper_method :sort_column

  def sort_direction
    params[:direction] || 'asc'
  end
  helper_method :sort_direction
end