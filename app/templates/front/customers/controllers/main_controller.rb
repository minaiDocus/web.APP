# frozen_string_literal: true

class Customers::MainController < OrganizationController

  before_action :load_customer, except: %w[index info new create search]
  before_action :verify_rights, except: 'index'
  before_action :verify_if_customer_is_active, only: %w[edit update edit_period_options update_period_options edit_knowings_options update_knowings_options edit_compta_options update_compta_options]
  before_action :verify_if_account_can_be_closed, only: %w[account_close_confirm close_account]

  prepend_view_path('app/templates/front/customers/views')

  # GET /organizations/:organization_id/customers
  def index
    respond_to do |format|
      format.html do
        if params[:group_ids].present?
          params[:user_contains][:group_ids] = params[:group_ids]
        end
        @customers = customers.search(search_terms(params[:user_contains]))
                              .order(sort_column => sort_direction)
                              .page(params[:page])
                              .per(params[:per_page])
        @periods = Period.where(user_id: @customers.pluck(:id)).where('start_date < ? AND end_date > ?', Date.today, Date.today).includes(:user, :product_option_orders)
        @groups = @user.groups.order(name: :asc)
      end

      format.json do
        @customers = search(user_contains).order(sort_column => sort_direction).active
      end
    end
  end

  # GET /organizations/:organization_id/customers/:id
  def show
    @subscription     = @customer.subscription
    @period           = @subscription.periods.order(created_at: :desc).first
    @journals         = @customer.account_book_types.order(name: :asc)
    @pending_journals = @customer.retrievers.where(journal_id: nil).where.not(journal_name: [nil]).distinct.pluck(:journal_name)
    
    build_softwares
  end

  def refresh_book_type
    render partial: 'book_type'
  end

  # GET /organizations/:organization_id/customers/new
  def new
    @customer = User.new(code: "#{@organization.code}%")
    build_softwares
    @customer.build_options   if @customer.options.nil?
  end

  # POST /organizations/:organization_id/customers
  def create
    @customer = Subscription::CreateCustomer.new(@organization, @user, user_params, current_user, request).execute

    unless @organization.specific_mission
      modif_params = params[:subscription][:subscription_option]
      params[:subscription][modif_params] = true
    end

    if @customer.persisted?
      if @organization.specific_mission
        redirect_to organization_customer_path(@organization, @customer)
      else
        Subscription::Form.new(@customer.subscription, @user, request).submit(params[:subscription])

        redirect_to organization_customer_path(@organization, @customer, tab: 'journals')
      end
    else
      flash[:error] = errors_to_list @customer.errors.messages

      redirect_to organization_customer_path(@organization, @customer)
    end
  end

  # GET /account/organizations/:organization_id/customers/:id/edit
  def edit; end

  # PUT /account/organizations/:organization_id/customers/:id
  def update
    if params[:part].present? && params[:part] == Interfaces::Software::Configuration.h_softwares[params[:part]] && user_params[softwares_attributes.to_sym].present?
      if params[:part] == 'my_unisoft'
        result = MyUnisoftLib::Setup.new({organization: @organization, customer: @customer, columns: {is_used: user_params[softwares_attributes.to_sym]['is_used'] == "1", action: params[:action]}}).execute
      else
        software = @customer.create_or_update_software({columns: user_params[softwares_attributes.to_sym], software: params[:part]})
        result   = software&.persisted?
      end

      if result
        flash[:success] = 'Modifié avec succès.'
      else
        flash[:error] = 'Impossible de modifier.'
      end

      redirect_to organization_customer_path(@organization, @customer, tab: params[:part])
    else
      @customer.is_group_required = @user.not_leader?

      if Subscription::UpdateCustomer.new(@customer, user_params).execute
        flash[:success] = 'Modifié avec succès'

        redirect_to organization_customer_path(@organization, @customer)
      else
        redirect_to organization_customer_path(@organization, @customer, tab: 'information')
      end
    end
  end

  def edit_software
    build_softwares
    @software = params[:software]
  end

  def update_software
    software = @customer.create_or_update_software({columns: user_params[softwares_attributes.to_sym], software: params[:part]})
    if software&.persisted?
      flash[:success] = 'Modifié avec succès.'
    else
      flash[:error] = 'Impossible de modifier.'
    end
    redirect_to organization_customer_path(@organization, @customer, tab: params[:software])
  end

  def edit_softwares_selection
    if @customer.configured?
      redirect_to organization_customer_path(@organization, @customer)
    else
      build_softwares
    end
  end

  def update_softwares_selection
    software = @customer.create_or_update_software({columns: user_params[softwares_attributes.to_sym], software: params[:part]})
    # TODO ... REMOVE STEP
  end

  # GET /account/organizations/:organization_id/customers/:id/edit_exact_online
  def edit_exact_online
    @customer.build_exact_online if @customer.exact_online.nil?
  end

  # PUT /account/organizations/:organization_id/customers/:id/update_exact_online
  def update_exact_online
    api_keys = @customer.exact_online.try(:api_keys)

    @customer.assign_attributes(exact_online_params)

    is_api_keys_changed = @customer.exact_online.try(:client_id) != api_keys.try(:[], :client_id) || @customer.exact_online.try(:client_secret) != api_keys.try(:[], :client_secret)

    if @customer.save
      if @customer.configured?
        flash[:success] = 'Modifié avec succès'

        if is_api_keys_changed && exact_online_params[:exact_online_attributes][:client_id].present? && exact_online_params[:exact_online_attributes][:client_secret].present?
          @customer.exact_online.try(:reset)
          redirect_to authenticate_account_exact_online_path(customer_id: @customer.id)
        else
          redirect_to organization_customer_path(@organization, @customer, tab: 'exact_online')
        end
      else
        # TODO ... REMOVE STEP
      end
    else
      flash[:error] = 'Impossible de modifier'
      render 'edit'
    end
  end

  # GET /account/organizations/:organization_id/customers/:id/edit_my_unisoft
  def edit_my_unisoft; end

  # PUT /account/organizations/:organization_id/customers/:id/update_my_unisoft
  def update_my_unisoft
    @customer.assign_attributes(my_unisoft_params)

    # is_api_token_changed = my_unisoft_params['encrypted_api_token'].try(:strip) == my_unisoft_params['check_api_token'].try(:strip)

    if @customer.save
      if @customer.configured?
          api_token       = my_unisoft_params["my_unisoft_attributes"]["encrypted_api_token"]
          remove_customer = my_unisoft_params["my_unisoft_attributes"]['encrypted_api_token'].blank? && my_unisoft_params["my_unisoft_attributes"]['check_api_token'] == "true"
          auto_deliver    = my_unisoft_params["my_unisoft_attributes"]['auto_deliver']

          MyUnisoftLib::Setup.new({organization: @organization, customer: @customer, columns: {api_token: api_token, remove_customer: remove_customer, auto_deliver: auto_deliver}}).execute

        flash[:success] = 'Modifié avec succès'

        redirect_to organization_customer_path(@organization, @customer, tab: 'my_unisoft')
      else
        # TODO ... REMOVE STEP
      end
    else
      flash[:error] = 'Impossible de modifier'
      render 'edit'
    end
  end

  # GET /account/organizations/:organization_id/customers/:id/edit_ibiza
  def edit_ibiza; end

  # PUT /account/organizations/:organization_id/customers/:id/update_ibiza
  def update_ibiza
    @customer.assign_attributes(ibiza_params)

    is_ibiza_id_changed = @customer.try(:ibiza).try(:ibiza_id_changed?)

    if @customer.save
      if @customer.configured?
        if is_ibiza_id_changed && @user.try(:ibiza).try(:ibiza_id?)
          AccountingPlan::IbizaUpdate.new(@user).run
        end

        flash[:success] = 'Modifié avec succès'

        redirect_to organization_customer_path(@organization, @customer, tab: 'ibiza')
      else
        # TODO ... REMOVE STEP
      end
    else
      flash[:error] = 'Impossible de modifier'
      render 'edit'
    end
  end


  # GET /organizations/:organization_id/customers/:id/edit_setting_options
  def edit_setting_options; end

  # PUT /organizations/:organization_id/customers/:id/update_setting_options
  def update_setting_options    
    if params[:pairing_code].present?
      @dematbox = @user.dematbox || Dematbox.create(user_id: @user.id)
      @dematbox.subscribe(params[:pairing_code])
      flash[:notice] = "Configuration de iDocus'Box en cours..."
    end

    if @customer.update(period_options_params) && @customer.update(compta_options_params)
      if @customer.configured?
        flash[:success] = 'Modifié avec succès.'
        redirect_to organization_customer_path(@organization, @customer, tab: 'compta')
      end
    else
      render 'edit_setting_options'
    end

  end

  # GET /account/organizations/:organization_id/customers/:id/edit_knowings_options
  def edit_knowings_options; end

  # PUT /account/organizations/:organization_id/customers/:id/update_knowings_options
  def update_knowings_options
    if @customer.update(knowings_options_params)
      if @customer.configured?
        flash[:success] = 'Modifié avec succès.'

        redirect_to organization_customer_path(@organization, @customer, tab: 'ged')
      else
        # TODO ... REMOVE STEP
      end
    else
      render 'edit_knowings_options'
    end
  end

  def upload_email_infos
    if @customer.authorized_upload? && @customer.active?
      render :upload_by_email
    else
      flash[:error] = t('authorization.unessessary_rights')
      redirect_to organization_customer_path(@organization, @customer)
    end
  end

  # GET /account/organizations/:organization_id/customers/:id/account_close_confirm
  def account_close_confirm; end

  # PUT /account/organizations/:organization_id/customers/:id/close_account
  def close_account
    if Subscription::Stop.new(@customer, params[:close_now]).execute
      flash[:success] = 'Dossier clôturé avec succès.'
    else
      flash[:error] = 'Impossible de clôturer immédiatement le dossier, la période a été en partie facturé.'
    end
    redirect_to organization_customer_path(@organization, @customer)
  end

  # /account/organizations/:organization_id/customers/:id/account_reopen_confirm
  def account_reopen_confirm; end

  # PUT /account/organizations/:organization_id/customers/:id/reopen_account(.:format)
  def reopen_account
    Subscription::Reopen.new(@customer, @user, request).execute
    flash[:success] = 'Dossier réouvert avec succès.'
    redirect_to organization_customer_path(@organization, @customer)
  end

  def search
    tags = []
    full_info = params[:full_info].present?
    if params[:q].present?
      users = @user.leader? ? @organization.customers.active : @user.customers.active
      users = users.where('code REGEXP :t OR company REGEXP :t OR first_name REGEXP :t OR last_name REGEXP :t', t: params[:q].split.join('|')).order(code: :asc).limit(10).select do |user|
        str = [user.code, user.company, user.first_name, user.last_name].join(' ')
        params[:q].split.detect { |e| !str.match(/#{e}/i) }.nil?
      end
      users.each do |user|
        tags << { id: user.id.to_s, name: full_info ? user.info : user.code }
      end
    end

    respond_to do |format|
      format.json { render json: tags.to_json, status: :ok }
    end
  end

  private

  def can_manage?
    @user.leader? || @user.manage_customers
  end

  def verify_rights
    authorized = true
    authorized = false unless can_manage?
    if action_name.in?(%w[account_close_confirm close_account]) && params[:close_now] == '1' && !@user.is_admin
      authorized = false
    end
    if action_name.in?(%w[info new create destroy]) && !@organization.is_active
      authorized = false
    end
    if action_name.in?(%w[info new create]) && !(@user.leader? || @user.groups.any?)
      authorized = false
    end
    if action_name.in?(%w[edit_period_options update_period_options]) && !@customer.authorized_upload?
      authorized = false
    end
    if action_name.in?(%w[edit_ibiza update_ibiza]) && !@organization.ibiza.try(:configured?)
      authorized = false
    end
    if action_name.in?(%w[edit_exact_online update_exact_online]) && !@organization.try(:exact_online).try(:used?)
      authorized = false
    end
    # if action_name.in?(%w[edit_my_unisoft update_my_unisoft]) && !@organization.try(:my_unisoft).try(:used?)
    #   authorized = false
    # end

    unless authorized
      flash[:error] = t('authorization.unessessary_rights')
      redirect_to organization_path(@organization)
    end
  end

  def verify_if_customer_is_active
    if @customer.inactive?
      flash[:error] = t('authorization.unessessary_rights')

      redirect_to organization_path(@organization)
    end
  end

  def verify_if_account_can_be_closed
    if !@customer.subscription.commitment_end?(false) && !params[:close_now]
      flash[:error] = 'Ce dossier est souscrit à un forfait avec un engagement de 12 mois'

      redirect_to organization_customer_path(@organization, @customer)
    end
  end

  def user_params
    attributes = [
      :company,
      :first_name,
      :last_name,
      :email,
      :is_pre_assignement_displayed,
      :act_as_a_collaborator_into_pre_assignment,
      :phone_number,
      :manager_id,
      :jefacture_account_id,
      { group_ids: [] },
      { options_attributes: %i[id is_taxable is_pre_assignment_date_computed default_banking_provider] },
      { options_attributes: %i[id is_taxable is_pre_assignment_date_computed] },
      { ibiza_attributes: %i[id is_used ibiza_id auto_deliver is_analysis_activated is_analysis_to_validate] },
      { exact_online_attributes: %i[id is_used auto_deliver client_id client_secret] },
      { my_unisoft_attributes: %i[id is_used auto_deliver encrypted_api_token check_api_token] },
      { coala_attributes: %i[id is_used auto_deliver] },
      { fec_agiris_attributes: %i[id is_used auto_deliver] },
      { cegid_attributes: %i[id is_used auto_deliver] },
      { quadratus_attributes: %i[id is_used auto_deliver] },
      { csv_descriptor_attributes: %i[id is_used auto_deliver use_own_csv_descriptor_format] }
    ]

    if @user.is_admin
      attributes[-1][:csv_descriptor_attributes] << :use_own_csv_descriptor_format
    end

    attributes << :code if action_name == 'create'

    params.require(:user).permit(*attributes)
  end

  def ibiza_params
    params.require(:user).permit(ibiza_attributes: %i[id ibiza_id auto_deliver is_analysis_activated is_analysis_to_validate])
  end

  def exact_online_params
    params.require(:user).permit(exact_online_attributes: %i[id client_id client_secret auto_deliver])
  end

  def my_unisoft_params
    params.require(:user).permit(my_unisoft_attributes: %i[id is_used auto_deliver encrypted_api_token check_api_token])
  end

  def configuration_options_params
    # TODO ...
  end

  def period_options_params
    if current_user.is_admin
      params.require(:user).permit(
        :authd_prev_period,
        :auth_prev_period_until_day,
        :auth_prev_period_until_month
      )
    else
      params.require(:user).permit(
        :authd_prev_period,
        :auth_prev_period_until_day
      )
    end
  end

  def knowings_options_params
    params.require(:user).permit(:knowings_code, :knowings_visibility)
  end

  def compta_options_params
    params.require(:user).permit(options_attributes: %i[
                                   id
                                   is_taxable
                                   is_pre_assignment_date_computed
                                   is_operation_processing_forced
                                   is_operation_value_date_needed
                                   preseizure_date_option
                                 ])
  end


  def build_softwares
    Interfaces::Software::Configuration::SOFTWARES.each do |software|
      @customer.send("build_#{software}".to_sym) if @customer.send(software.to_sym).nil?
    end
  end
  

  def softwares_attributes
    "#{Interfaces::Software::Configuration.h_softwares[params[:part]]}_attributes"
  end

  def load_customer
    @customer = customers.find(params[:id])
  end

  def sort_column
    params[:sort] || 'created_at'
  end
  helper_method :sort_column

  def sort_direction
    params[:direction] || 'desc'
  end
  helper_method :sort_direction

  def is_max_number_of_journals_reached?
    @customer.account_book_types.count >= @customer.options.max_number_of_journals
  end
  helper_method :is_max_number_of_journals_reached?
end