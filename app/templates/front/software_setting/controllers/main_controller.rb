# frozen_string_literal: true
class SoftwareSetting::MainController < OrganizationController
  prepend_view_path('app/templates/front/software_setting/views')

  def index; end

  def update
    software = params[:software]
    soft_params = software_params["#{software}_attributes"]
    result = update_software(software, soft_params[:is_used] == "1", soft_params[:auto_deliver] == "1")
    
    software_users = params[:software_account_list] || ''
    @organization.customers.active.each do |customer|
      softwares_params = nil

      if software == 'ibiza'
        softwares_params = { columns: { is_used: (software_users.include?(customer.to_s) && !customer.uses?(:exact_online)) }, software: 'ibiza' }
      elsif software == 'exact_online'
        softwares_params = { columns: { is_used: (software_users.include?(customer.to_s) && !customer.uses?(:ibiza)) }, software: 'exact_online' }
      else
        softwares_params = { columns: { is_used: software_users.include?(customer.to_s) }, software: software }
      end

      unless softwares_params.nil?
        customer.create_or_update_software(softwares_params)
      end
    end

    flash[:success] = 'Modifié avec succès'

    redirect_to softwares_list_path(@organization.id, tab: params[:software])
  end
  
  def activate
    result = update_software(params[:software], true, false)

    if result
      flash[:success] = 'Activé avec succès'
    else
      flash[:error]   = 'Erreur de mise à jour'
    end

    redirect_to softwares_list_path(@organization.id, tab: params[:software])
  end

  def deactivate
    result = update_software(params[:software], false, false)

    if result
      flash[:success] = 'Désactivé avec succès'
    else
      flash[:error]   = 'Erreur de mise à jour'
    end

    redirect_to softwares_list_path(@organization.id)
  end

  private

  def update_software(soft, is_used, auto_deliver=false)
    if soft == 'my_unisoft'
      result = MyUnisoftLib::Setup.new({organization: @organization, columns: {is_used: is_used, auto_deliver: auto_deliver}}).execute 
    else
      result = Software::UpdateOrCreate.assign_or_new({owner: @organization, columns: {is_used: is_used, auto_deliver: auto_deliver}, software: soft})
    end

    result
  end

  def software_params
    params.require(:organization).permit(
      { :quadratus_attributes => %i[id is_used auto_deliver] },
      { :coala_attributes => %i[id is_used auto_deliver] },
      { :cegid_attributes => %i[id is_used auto_deliver] },
      { :fec_agiris_attributes => %i[id is_used auto_deliver] },
      { :fec_acd_attributes => %i[id is_used auto_deliver] },
      { :csv_descriptor_attributes => %i[id is_used auto_deliver] },
      { :exact_online_attributes => %i[id is_used auto_deliver] },
      { :my_unisoft_attributes => %i[id is_used auto_deliver] }
    )
  end
end