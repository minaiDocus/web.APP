# frozen_string_literal: true
class Dashboard::MainController < TemplatesController
  append_view_path('app/templates/front/dashboard/views')

  def index; end

  def my_favorite_customers
    @favorites = []

    5.times do |i|
      fav = FakeObject.new
      fav.name = "Test - #{i+1}"
      fav.note = "bon"
      fav.badge = "sucess"
      fav.info = "Ceci est le test n°#{i+1}"

      @favorites << fav
    end
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
end