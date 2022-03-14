module V2::Invoice
  extend ActiveSupport::Concern

  included do
    validates_presence_of :period_v2

    scope :of_period, -> (period){ where(period: period) }
  end
end