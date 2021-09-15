# frozen_string_literal: true
class Ibiza::MainController < OrganizationController
  before_action :verify_rights
  before_action :load_ibiza, except: :create

  prepend_view_path('app/templates/front/ibiza/views')

  # POST /organizations/:organization_id/ibiza
  def create
    @ibiza = Software::Ibiza.new(ibiza_params)
    @ibiza.owner = @organization

    if @ibiza.save
      if @ibiza.need_to_verify_access_tokens?
        IbizaLib::VerifyAccessTokens.new(@ibiza.id.to_s).execute
      end

      json_flash[:success] = 'Créé avec succès.'
    else
      json_flash[:error] = @ibiza.errors.messages.join('; ')
    end

    render json: { json_flash: json_flash }, status: 200
  end

  # GET /organizations/:organization_id/ibiza/edit
  def edit; end

  # PUT /organizations/:organization_id/ibiza
  def update
    if @ibiza.update(ibiza_params)
      if @ibiza.need_to_verify_access_tokens?
        IbizaLib::VerifyAccessTokens.new(@ibiza.id.to_s).execute
      end

      json_flash[:success] = 'Modifié avec succès.'
    else
      json_flash[:error] = @ibiza.errors.messages.join('; ')
    end

    render json: { json_flash: json_flash }, status: 200
  end

  private

  def verify_rights
    unless @user.leader?
      flash[:error] = t('authorization.unessessary_rights')
      redirect_to organization_path(@organization)
    end
  end

  def load_ibiza
    @ibiza = @organization.ibiza
  end

  def ibiza_params
    params.require(:software_ibiza).permit(:specific_url_options, :ibiza_id, :access_token, :access_token_2, :auto_deliver, :is_analysis_activated, :is_analysis_to_validate, :description_separator, :piece_name_format_sep, :voucher_ref_target).tap do |whitelist|
      whitelist[:description]       = JSON.parse(params[:software_ibiza][:description]).with_indifferent_access
      whitelist[:piece_name_format] = JSON.parse(params[:software_ibiza][:piece_name_format]).with_indifferent_access
    end
  end
end