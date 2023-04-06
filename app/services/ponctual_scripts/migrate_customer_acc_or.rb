class PonctualScripts::MigrateCustomerAccOr < PonctualScripts::PonctualScript
  def self.execute
    new().run
  end

  def self.rollback
    new().rollback
  end

  private

  def execute
    @customer_dst = User.find_by_code 'OR%19990'
    # @customer_dst = User.find_by_code 'IDOC%XXX'
    @org_dst      = @customer_dst.organization_id

    ['AC0000', 'ACC%AUD'].each do |user_code|
      @customer_src = User.find_by_code user_code

      migrate_customers
    end
  end

  def backup
    # @customer_src = User.find_by_code 'IDOC%XXX'
    # @customer_dst = User.find_by_code 'ACC%AUD'

    # @org_dst = @customer_dst.organization_id

    # migrate_customers
  end

  def models
    [Pack, Pack::Report, Pack::Piece, Pack::Report::Preseizure, Pack::Report::Expense, Operation, TempDocument, TempPack, PeriodDocument]
  end

  def migrate_customers
    logger_infos "[MigrationCustomer] - Start"

    response = {}

    models.each do |mod|
      datas  = mod.to_s == 'Pack' ? mod.unscoped.where(owner_id: @customer_src.id) : mod.unscoped.where(user_id: @customer_src.id)
      target = mod.to_s == 'Pack' ? 'owner_id' : 'user_id'

      if datas.first.respond_to?(:organization_id) && datas.first.try(:organization_id).to_i > 0
        datas.update_all("#{target}"=> @customer_dst.id, organization_id: @org_dst)
      else
        datas.update_all("#{target}"=> @customer_dst.id)
      end

      response[mod.to_s] = datas.pluck(:id)
    end

    log_document = {
      subject: "[MigrateCustomer] - ACC TO OR",
      name: "AccToOr",
      error_group: "[MigrateCustomer] - ACC TO OR",
      erreur_type: "[MigrateCustomer] - ACC TO OR",
      date_erreur: Time.now.strftime('%Y-%m-%d %H:%M:%S'),
      more_information: response
    }

    ErrorScriptMailer.error_notification(log_document).deliver

    logger_infos "[Response] - #{response.to_json}"

    logger_infos "[MigrationCustomer] - End"
  end
end