class Management::DataFlow < ApplicationRecord
  self.table_name = 'data_flows'

  belongs_to :user

  validates_presence_of :period, :user

  scope :of_period, ->(period){ where(period: period.to_i) }

  def all_compta_transactions
    self.compta_pieces + self.compta_operations
  end
end