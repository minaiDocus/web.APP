# frozen_string_literal: true

class Front::IndexController < ApplicationController
  before_action :login_user!

  # append_view_path('app/views/front/layouts')

  def index
    render 'front/layouts/layout'
  end

  def my_favorite_customers
    my_favorite_customers_list = [
      {'name' => 'TEST', 'note' => 'bon', 'badge' => 'sucess', 'info' => 'Test test fake data'},
      {'name' => 'iDocus', 'note' => 'critiqué', 'badge' => 'critical', 'info' => 'iDocus test'},
      {'name' => 'ABCD', 'note' => 'Moyen', 'badge' => 'warning', 'info' => 'ABCD test'}
    ]

    render json: { success: true, my_favorite_customers: my_favorite_customers_list }, status: 200
  end

  def add_customer_to_favorite
    my_favorite_customers_list = [
      {'name' => 'TEST', 'note' => 'bon', 'badge' => 'sucess', 'info' => 'Test test fake data'},
      {'name' => 'iDocus', 'note' => 'critiqué', 'badge' => 'critical', 'info' => 'iDocus test'},
      {'name' => 'ABCD', 'note' => 'Moyen', 'badge' => 'warning', 'info' => 'ABCD test'}
    ]

    params[:my_favorite_customers].each do |name|
      my_favorite_customers_list << {name: name, note: 'Bon', badge: 'success', info: 'iDocus test post'}
    end

    render json: { success: true, my_favorite_customers: my_favorite_customers_list }, status: 200
  end


  def notifications
    _notifications = [
      {'id' => '1', 'title' => '1 erreur détectée', 'date' => 'Aujourd’hui à 13:15', 'content' => 'IDOC%001 : obligatoire exercice comptable'},
      {'id' => '2', 'title' => '1 erreur détectée', 'date' => 'Hier à 13:15', 'content' => 'IDOC%001 : obligatoire exercice comptable'},
      {'id' => '3', 'title' => '1 erreur détectée', 'date' => 'Hier à 10:15', 'content' => 'IDOC%001 : obligatoire exercice comptable'}
    ]

    render json: { success: true, notifications: _notifications }, status: 200
  end

  def my_organization_groups

  end
end
