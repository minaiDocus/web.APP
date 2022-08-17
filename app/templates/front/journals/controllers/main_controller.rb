# frozen_string_literal: true

class Journals::MainController < OrganizationController
  before_action :init_vars, only: %w[add_rubric]
  before_action :load_customer, except: %w[index]
  before_action :verify_rights
  before_action :verify_if_customer_is_active
  before_action :load_journal, only: %w[edit update destroy update_analytics delete_analytics sync_analytics]
  before_action :verify_max_number, only: %w[new create select copy]

  prepend_view_path('app/templates/front/journals/views')

  # GET /organizations/:organization_id/journals
  def index
    @journals = @organization.account_book_types.order(is_default: :desc, name: :asc).page(params[:page]).per(params[:per_page])
  end

  # GET /organizations/:organization_id/journals/new
  def new
    @journal = AccountBookType.new
  end

  # POST /organizations/:organization_id/journals
  def create
    @journal = Journal::Handling.new({ owner: (@customer || @organization), params: journal_params, current_user: current_user, request: request }).insert
    if !@journal.errors.messages.present?
      text = "Nouveau journal #{ @journal.name } créé avec succès"

      if params[:new_create_book_type].present?
        render json: { success: true, response: { text: text } }, status: 200
      else
        json_flash[:success] = text
        if @customer
          render json: { json_flash: json_flash, response_url: organization_user_journals_path(@organization, @customer) }
        else
          render json: { json_flash: json_flash, response_url: organization_journals_path(@organization) }
        end
      end
    else
      json_flash[:error] = errors_to_list @journal

      if params[:new_create_book_type].present?
        render json: { success: true, response: @journal.errors.messages }, status: 200
      else
        if @customer
          render json: { json_flash: json_flash, response_url: organization_user_journals_path(@organization, @customer) }
        else
          render json: { json_flash: json_flash, response_url: organization_journals_path(@organization) }
        end
      end
    end
  end

  # PUT /organizations/:organization_id/journals/:journal_id/edit_analytics
  def update_analytics
    if @customer
      analytic_reference = Journal::AnalyticReferences.new(@journal)
      if analytic_reference.add(params[:analysis][:analytic])
        json_flash[:success] = 'Modifié avec succès.'
      else
        json_flash[:error] = analytic_reference.error_messages
      end
    else
      json_flash[:error] = t('authorization.unessessary_rights')
    end

    render json: { json_flash: json_flash }, status: 200
  end

  def sync_analytics
    if @customer
      analytic_reference = Journal::AnalyticReferences.new(@journal)
      if analytic_reference.synchronize
        flash[:success] = 'Synchronisé avec succès.'
      else
        flash[:error]   = "Erreur de synchronisation - #{analytic_reference.error_messages}"
      end
      redirect_to edit_analytics_organization_customer_journals_path(@organization, @customer, id: @journal)
    else
      flash[:error] = t('authorization.unessessary_rights')
      redirect_to organization_journals_path(@organization)
    end
  end

  # GET /organizations/:organization_id/journals/edit
  def edit; end

  # PUT /organizations/:organization_id/journals/:journal_id
  def update
    journal = Journal::Handling.new({journal: @journal, params: journal_params, current_user: current_user, request: request}).update

    if !journal.errors.messages.present?
      text = "Le journal #{journal.name} a été modifié avec succès."

      if params[:new_create_book_type].present?
        render json: { success: true, response: { text: text } }, status: 200
      else
        json_flash[:success] = text
        if @customer
          render json: { json_flash: json_flash, response_url: organization_user_journals_path(@organization, @customer) }
        else
          render json: { json_flash: json_flash, response_url: organization_journals_path(@organization) }
        end
      end
    else
      json_flash[:error] = errors_to_list journal

      if params[:new_create_book_type].present?
        render json: { success: true, response: journal.errors.messages }, status: 200
      else
         if @customer
          render json: { json_flash: json_flash, response_url: organization_user_journals_path(@organization, @customer) }
        else
          render json: { json_flash: json_flash, response_url: organization_journals_path(@organization) }
        end
      end
    end
  end

  # DELETE /organizations/:organization_id/journals/:journal_id
  def destroy
    if @user.is_admin || Settings.first.is_journals_modification_authorized || !@customer || @journal.is_open_for_modification?
      Journal::Handling.new({journal: @journal, current_user: current_user, request: request}).destroy
      
      if @customer
        json_flash[:success] = 'Supprimé avec succès.'
        render json:{ json_flash: json_flash }, status: 200
      else
        flash[:success] = 'Supprimé avec succès.'
        redirect_to organization_journals_path(@organization)
      end
    else
      flash[:error] = t('authorization.unessessary_rights')
      redirect_to root_path
    end
  end

  # GET /organizations/:organization_id/journals/:journal_id/select
  def select
    @journals = @organization.account_book_types.order(is_default: :desc).order(name: :asc).page(params[:page]).per(params[:per_page])
  end

  # GET /organizations/:organization_id/journals/:journal_id/copy
  def copy
    valid_ids = @organization.account_book_types.map(&:id).map(&:to_s)

    ids = (params[:journal_ids].presence || []).select do |journal_id|
      journal_id.in? valid_ids
    end

    copied_ids = []

    ids.each do |id|
      next if is_max_number_reached?

      journal = AccountBookType.find id

      #next unless !journal.compta_processable? || is_preassignment_authorized?

      copy              = journal.dup
      copy.user         = @customer
      copy.organization = nil
      copy.is_default   = nil

      next unless copy.save

      copied_ids << id

      Journal::UpdateRelation.new(copy).execute

      CreateEvent.add_journal(copy, @customer, current_user, path: request.path, ip_address: request.remote_ip)
    end

    if ids.count == 0
      json_flash[:error] = 'Aucun journal sélectionné.'
    elsif copied_ids.count == 0
      json_flash[:error] = 'Aucun journal copié.'
    elsif ids.count == copied_ids.count
      json_flash[:success] = "#{copied_ids.count} journal(s) copié(s)."
    else
      json_flash[:notice] = "#{copied_ids.count}/#{ids.count} journal(s) copié(s)."
    end

    FileImport::Dropbox.changed(@customer) if copied_ids.count > 0

    render json: { json_flash: json_flash }, status: 200
  end

  def add_rubric
    json_flash = {} ##TODO: global var json_flash is not working here, don't know why?

    if is_max_number_reached?
      json_flash[:error] = 'Vous avez atteint le nombre maximum de rubrique'
    else
      @journal = Journal::Handling.new({ owner: @customer, params: rubric_params, current_user: current_user, request: request }).insert_ged
      if @journal && !@journal.errors.messages.present?
        json_flash[:success] = "Rubrique #{ @journal.label } créé avec succès"
      else
        if @journal
          json_flash[:error] = errors_to_list @journal
        else
          json_flash[:error] = 'Impossible de créer la rubrique, Veuillez réessayer ultérieurement.'
        end
      end
    end

    render json: { json_flash: json_flash }, status: 200
  end

  private

  def init_vars
    @customer     = User.find params[:customer_id]
    @organization = @customer.organization
  end

  def verify_rights
    is_ok = false
    if @organization.is_active
      is_ok = true if @user.leader?
      is_ok = true if !is_ok && !@customer && @user.manage_journals
      is_ok = true if !is_ok && @customer && @user.manage_customer_journals
    end
    unless is_ok
      flash[:error] = t('authorization.unessessary_rights')
      redirect_to organization_path(@organization)
    end
  end

  def verify_if_customer_is_active
    if @customer&.inactive?
      flash[:error] = t('authorization.unessessary_rights')
      redirect_to organization_path(@organization)
    end
  end

  def journal_params
    attrs = %i[
      label
      pseudonym
      use_pseudonym_for_import
      description
      instructions
      position
      is_default
    ]

    if @user.is_admin || Settings.first.is_journals_modification_authorized || !@customer || !@journal || @journal.is_open_for_modification?
      attrs << :name
    end

    if is_preassignment_authorized? || @customer.my_package.try(:bank_active)
      attrs += %i[
        domain
        entry_type
        currency
        account_type
        meta_account_number
        meta_charge_account
        vat_accounts
        anomaly_account
        jefacture_enabled
      ]
    end

    attrs << :is_expense_categories_editable if current_user.is_admin
    attributes = params.require(:account_book_type).permit(*attrs)

    if @journal&.is_expense_categories_editable || current_user.is_admin
      if params[:account_book_type][:expense_categories_attributes].present?
        attributes[:expense_categories_attributes] = params[:account_book_type][:expense_categories_attributes].permit!
      end
    end

    attributes[:jefacture_enabled] = attributes[:jefacture_enabled].to_s.gsub('1', 'true').gsub('0', 'false') if is_preassignment_authorized?
    attributes
  end

  def rubric_params
    attrs = %i[label]

    attributes = params.require(:account_book_type).permit(*attrs)

    attributes
  end

  def load_customer
    if params[:customer_id].present?
      @customer = customers.find params[:customer_id]
    end
  end

  def load_journal
    @journal = (@customer || @organization).account_book_types.find params[:id]
  end

  def is_max_number_reached?
    return false if @customer.organization.specific_mission

    @customer.account_book_types.count >= @customer.my_package.try(:journal_size).to_i
  end
  helper_method :is_max_number_reached?

  def is_preassignment_authorized?
    @customer.nil? || @customer.my_package.try(:preassignment_active) || @organization.specific_mission || @customer.my_package.try(:bank_active)
  end
  helper_method :is_preassignment_authorized?

  def verify_max_number
    if @customer && is_max_number_reached?
      text = "Nombre maximum de journaux comptables atteint : #{@customer.account_book_types.count}/#{@customer.my_package.try(:journal_size).to_i}."
      if params[:new_create_book_type].present?
        render json: { success: true, response: text }, status: 200
      else
        flash[:error] = text
        redirect_to organization_user_journals_path(@organization, @customer)
      end
    end
  end
end