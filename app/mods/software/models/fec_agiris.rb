class SoftwareMod::FecAgiris < ApplicationRecord
  include Interfaces::Software::Configuration

  self.table_name = "software_fec_agiris"

  belongs_to :owner, polymorphic: true

  validates_inclusion_of :auto_deliver, in: [-1, 0, 1]
end
