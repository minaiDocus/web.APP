# -*- encoding : UTF-8 -*-
class BillingMod::V1::ExtraOrder < ApplicationRecord
  self.table_name = 'extra_orders'

  belongs_to :owner, polymorphic: true, optional: true

  scope :of_period, -> (period){ where(period: period) }
end
