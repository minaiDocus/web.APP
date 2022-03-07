# -*- encoding : UTF-8 -*-
class Ticket < ApplicationRecord
  belongs_to :user 

  before_create :set_user_code

  def self.search(contains)
    events = self.all

    events = events.where(id:          contains[:id])          if contains[:id].present?
    events = events.where(action:      contains[:action])      if contains[:action].present?
    events = events.where(target_type: contains[:target_type]) if contains[:target_type].present?
    events = events.where("target_name LIKE ?", "%#{contains[:target_name]}%") if contains[:target_name].present?

    events
  end

  private

  def set_user_code
    self.user_code ||= user.try(:code)
  end
end
