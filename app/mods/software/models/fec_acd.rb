class SoftwareMod::FecAcd< ApplicationRecord
  include SoftwareMod::Configuration

  self.table_name = "software_fec_acds"

  belongs_to :owner, polymorphic: true

  validates_inclusion_of :auto_deliver, in: [-1, 0, 1]
end
