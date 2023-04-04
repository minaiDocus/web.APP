class PonctualScripts::MigrateCustomerAccOr < PonctualScripts::PonctualScript
  def self.execute
    new().run
  end

  def self.rollback
    new().rollback
  end

  private

  def execute
    @customer_src = User.find_by_code 'ACC%AUD'
    @customer_dst = User.find_by_code 'OR%19990'

    migrate_customers
  end

  def backup
    @customer_src = User.find_by_code 'OR%19990'
    @customer_dst = User.find_by_code 'ACC%AUD'

    migrate_customers
  end

  def models
    [Pack, Pack::Report, Pack::Piece, Pack::Report::Preseizure, Pack::Report::Expense, Operation, TempDocument, TempPack]
  end

  def migrate_customers
    logger_infos "[MigrationCustomer] - Start"

    models.each do |mod|
      datas = mod.to_s == 'Pack' ? mod.unscoped.where(owner_id: @customer_src.id) : mod.unscoped.where(user_id: @customer_src.id)

      datas.each { |data| mod.to_s == 'Pack' ? data.update(owner_id: @customer_dst.id) : data.update(user_id: @customer_dst.id) }
    end

    logger_infos "[MigrationCustomer] - End"
  end
end