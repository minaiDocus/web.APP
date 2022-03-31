module V2::SubscriptionOption
  extend ActiveSupport::Concern

  included do
    belongs_to :owner, polymorphic: true, optional: true

    scope :of_period, -> (period){ where(period: period) }
  end 
end