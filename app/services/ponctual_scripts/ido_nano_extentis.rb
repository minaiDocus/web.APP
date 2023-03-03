class PonctualScripts::IdoNanoExtentis < PonctualScripts::PonctualScript
  def self.execute
    new().run
  end

  def self.rollback
    new().rollback
  end

  private

  def execute
    extents_exception = %w[FBC%HABHAB FBC%CLESENMAIN FIDC%LAHOUAR EG%DEGAULEJAC EG%LEGALL EXT%COSICH]
    organization      = Organization.find_by_code 'EXT'
    customers         = organization.customers.active_at(Time.now)
    period            = CustomUtils.period_of(Time.now)

    customers.each do |customer|
      package = customer.my_package

      next if package.name == 'ido_nano'
      logger_infos "[IdoNanoExtentis] - customers code : #{customer.code.to_s} - Start"

      package.bank_active             = false if ["ido_micro", "ido_micro_plus"].include?(package.name) && extents_exception.include?(customer.code)
      package.name                    = 'ido_nano'
      package.commitment_start_period = period
      package.commitment_end_period   = CustomUtils.period_of(12.month.after)

      if package.save
        logger_infos "[IdoNanoExtentis] - customers code : #{customer.code.to_s} - Finished"
      else
        logger_infos "[IdoNanoExtentis] - customers code : #{customer.code.to_s} - Failed - message : #{package.errors.messages.to_s}"
      end
    end
  end

  def backup; end
end