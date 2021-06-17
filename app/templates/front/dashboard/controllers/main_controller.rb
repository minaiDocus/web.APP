# frozen_string_literal: true
class Dashboard::MainController < FrontController
  append_view_path('app/templates/front/dashboard/views')

  def index
     @favorites = []

    3.times do |i|
      fav = FakeObject.new
      fav.id = "good_#{i}"
      fav.name = "Test good- #{i+1}"
      fav.note = "Bon"
      fav.state = "good"
      fav.info = "Ceci est le test n°#{i+1}"

      @favorites << fav
    end

    3.times do |i|
      fav = FakeObject.new
      fav.id = "medium_#{i}"
      fav.name = "Test moyen- #{i+1}"
      fav.note = "Moyen"
      fav.state = "medium"
      fav.info = "Ceci est le test n°#{i+1}"

      @favorites << fav
    end

    3.times do |i|
      fav = FakeObject.new
      fav.id = "critical_#{i}"
      fav.name = "Test critique- #{i+1}"
      fav.note = "Critique"
      fav.state = "critical"
      fav.info = "Ceci est le test n°#{i+1}"

      @favorites << fav

      @favorites.flatten

      @favorites = []
    end

    # @favorites
  end

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
    # my_favorite_customers_list = [
    #   {'name' => 'TEST', 'note' => 'bon', 'badge' => 'sucess', 'info' => 'Test test fake data'},
    #   {'name' => 'iDocus', 'note' => 'critiqué', 'badge' => 'critical', 'info' => 'iDocus test'},
    #   {'name' => 'ABCD', 'note' => 'Moyen', 'badge' => 'warning', 'info' => 'ABCD test'}
    # ]

    # params[:my_favorite_customers].each do |name|
    #   my_favorite_customers_list << {name: name, note: 'Bon', badge: 'success', info: 'iDocus test post'}
    # end

    # render json: { success: true, my_favorite_customers: my_favorite_customers_list }, status: 200


    @favorites = []

    3.times do |i|
      fav = FakeObject.new
      fav.id = "good_#{i}"
      fav.name = "Test good- #{i+1}"
      fav.note = "Bon"
      fav.state = "good"
      fav.info = "Ceci est le test n°#{i+1}"

      @favorites << fav
    end

    3.times do |i|
      fav = FakeObject.new
      fav.id = "medium_#{i}"
      fav.name = "Test moyen- #{i+1}"
      fav.note = "Moyen"
      fav.state = "medium"
      fav.info = "Ceci est le test n°#{i+1}"

      @favorites << fav
    end

    3.times do |i|
      fav = FakeObject.new
      fav.id = "critical_#{i}"
      fav.name = "Test critique- #{i+1}"
      fav.note = "Critique"
      fav.state = "critical"
      fav.info = "Ceci est le test n°#{i+1}"

      @favorites << fav      
    end

    3.times do |i|
      fav = FakeObject.new
      fav.id = "add_#{i}"
      fav.name = "Test add- #{i+1}"
      fav.note = "Moyen"
      fav.state = "good"
      fav.info = "Ceci est le add n°#{i+1}"

      @favorites << fav
    end    

    @favorites.flatten

    render partial: 'favorite_customers', locals: { collection: @favorites }
  end

  def choose_default_summary
    @user.options.update(dashboard_default_summary: params[:service_name])
    redirect_to dashboard_main_index_path
  end

  def last_scans
    @last_kits = Rails.cache.fetch ['user', @user.id, 'last_kits'], expires_in: 5.minutes do
      PaperProcess.where(user_id: user_ids).kits.order(updated_at: :desc).includes(user: :organization).limit(5).to_a
    end
    @last_receipts = Rails.cache.fetch ['user', @user.id, 'last_receipts'], expires_in: 5.minutes do
      PaperProcess.where(user_id: user_ids).receipts.order(updated_at: :desc).includes(user: :organization).limit(5).to_a
    end
    @last_scanned = Rails.cache.fetch ['user', @user.id, 'last_scanned'], expires_in: 5.minutes do
      PeriodDocument.where(user_id: user_ids).where.not(scanned_at: [nil]).order(scanned_at: :desc).includes(:pack).limit(5).to_a
    end
    @last_returns = Rails.cache.fetch ['user', @user.id, 'last_returns'], expires_in: 5.minutes do
      PaperProcess.where(user_id: user_ids).returns.order(updated_at: :desc).includes(user: :organization).limit(5).to_a
    end

    render partial: 'last_scans'
  end

  def last_uploads
    @last_uploads = Rails.cache.fetch ['user', @user.id, 'last_uploads', temp_documents_key] do
      TempDocument.where(user_id: user_ids).where.not(original_file_name: nil).upload.order(created_at: :desc).includes({ user: :organization }, :piece, :temp_pack).limit(10).to_a
    end

    render partial: 'last_uploads'
  end

  def last_dematbox_scans
    @last_dematbox_scans = Rails.cache.fetch ['user', @user.id, 'last_dematbox_scans', temp_documents_key] do
      TempDocument.where(user_id: user_ids).dematbox_scan.order(created_at: :desc).includes({ user: :organization }, :piece, :temp_pack).limit(10).to_a
    end

    render partial: 'last_dematbox_scans'
  end

  def last_retrieved
    @last_retrieved = Rails.cache.fetch ['user', @user.id, 'last_retrieved', temp_documents_key] do
      TempDocument.where(user_id: user_ids).retrieved.order(created_at: :desc).includes({ user: :organization }, :piece, :temp_pack).limit(10).to_a
    end

    @last_operations = Rails.cache.fetch ['user', @user.id, 'last_operations', operations_key] do
      Operation.where(user_id: user_ids).order(created_at: :desc).includes({ user: :organization }, :bank_account).limit(10).to_a
    end

    render partial: 'last_retrieved'
  end

  private

  def user_ids
    @user_ids ||= accounts.active.map(&:id).sort
  end

  def get_key_for(_name)
    timestamps = user_ids.map do |user_id|
      # Rails.cache.fetch ['user', user_id, name, 'last_updated_at'] { Time.now.to_i }
    end
    Digest::MD5.hexdigest timestamps.join('-')
  end

  def temp_documents_key
    get_key_for 'temp_documents'
  end

  def operations_key
    get_key_for 'operations'
  end
end