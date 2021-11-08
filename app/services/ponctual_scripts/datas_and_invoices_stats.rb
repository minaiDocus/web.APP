class PonctualScripts::DatasAndInvoicesStats < PonctualScripts::PonctualScript
  def self.execute
    new().run
  end

  def self.rollback
    new().rollback
  end

  private

  def execute
    #Change preseizure excess prices first
    change_prices(12, 25)

    


    #rollback prices in the end
    change_prices(25, 12)
  end

  def backup; end


  def change_prices(prev_price, new_price)
    subscriptions = Subscription.where(unit_price_of_excess_preseizure: prev_price); nil
    subscriptions.update_all({ unit_price_of_excess_preseizure: new_price, unit_price_of_excess_expense: new_price }); nil

    periods = Period.where(unit_price_of_excess_preseizure: prev_price); nil
    periods.update_all({ unit_price_of_excess_preseizure: new_price, unit_price_of_excess_expense: new_price }); nil
  end
end