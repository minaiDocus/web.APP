# -*- encoding : UTF-8 -*-
class SoftwareMod::MyUnisoft < ApplicationRecord
  include SoftwareMod::Configuration

  self.table_name = "software_my_unisofts"

  belongs_to :owner, polymorphic: true

  attr_encrypted :api_token, random_iv: true

  validates_inclusion_of :auto_deliver, in: [-1, 0, 1]

  def configured?
    name.present? && society_id.present? && member_id.present?  	
  end

  def auto_update_accounting_plan?
    is_auto_updating_accounting_plan
  end
end