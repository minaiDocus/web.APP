class SoftwareMod::Quadratus < ApplicationRecord
  include Interfaces::Software::Configuration

  self.table_name = "software_quadratus"

  belongs_to :owner, polymorphic: true

  validates_inclusion_of :auto_deliver, in: [-1, 0, 1]
end
