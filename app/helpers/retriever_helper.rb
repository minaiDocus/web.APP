# frozen_string_literal: true

module RetrieverHelper
  def retriever_dyn_attrs(retriever)
    hsh = {}
    5.times do |i|
      param_name = "param#{i + 1}"
      data = retriever.send(param_name)
      next unless data

      data = data.dup # data is frozen due to encryption so we use a duplicate
      data['error'] = retriever.errors[param_name].first
      data['value'] = nil if data['type'] == 'password'
      hsh[param_name] = data
    end
    hsh.to_json
  end

  def state_of(retriever)
    states =  {
                '': '-',
                'ready': 'OK',
                'configuring': 'Synchronisation en cours',
                'destroying': 'Suppression en cours',
                'waiting_selection': 'Sélection de documents',
                'waiting_additionnal_info': "En attente de l'utilisateur",
                'error': 'Erreur',
                'unavailable': 'Indisponible'
              }

    states[retriever.state.to_sym]
  end

  def badge_type_of(retriever)
    if ['ready', 'configuring', 'waiting_selection', 'waiting_additionnal_info'].include? retriever.state
      'success'
    else
      'danger'
    end
  end

  def customers_active
    if @user.organization.specific_mission
      accounts.map { |u| [u, u.id] } || []
    else
      accounts.active.map { |u| [u, u.id] } || []
    end
  end

  def retriever_customers
    accounts.active.select do |customer|
      customer.options.is_retriever_authorized
    end.map{ |u| [u, u.id] } || []
  end

  # def link_retriever_options(account)
  #   { class: account.try(:id)? '' : 'disabled', title: account.try(:id)? '' : 'Sélectionnez un dossier pour pouvoir poursuivre' }
  # end
end
