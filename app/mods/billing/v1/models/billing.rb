class BillingMod::V1::Billing < ApplicationRecord
  self.table_name = 'billings'

  serialize :associated_hash, Hash

  belongs_to :owner, polymorphic: true

  validates_presence_of :period, :name
  validates_inclusion_of :kind, in: ['normal', 'discount', 'excess', 're-sit', 'order', 'extra']

  scope :of_period, ->(period){ where(period: period.to_i) }
end