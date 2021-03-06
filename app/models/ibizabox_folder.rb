class IbizaboxFolder < ApplicationRecord

  belongs_to :user, optional: true
  belongs_to :journal, class_name: 'AccountBookType', optional: true

  has_many   :temp_documents

  validates_presence_of :user, :journal

  scope :ready, -> { where(state: 'ready') }
  scope :ready_or_blocked_processing, -> { where("state = ? OR (updated_at < ? AND state = ?)", 'ready', 1.hours.ago, 'processing') }
  scope :not_recently_checked, -> { where('last_checked_at IS NULL OR last_checked_at < ?', 3.hours.ago) }

  def active?
    !inactive?
  end

  state_machine initial: :inactive do
    state :inactive
    state :ready
    state :processing
    state :waiting_selection

    before_transition any => [:inactive] do |folder, transition|
      folder.is_selection_needed = true
    end

    event :enable do
      transition [:inactive] => :ready
    end

    event :disable do
      transition [:ready, :waiting_selection] => :inactive
    end

    event :process do
      transition [:ready] => :processing
    end

    event :wait_selection do
      transition [:processing] => :waiting_selection
    end

    event :ready do
      transition [:processing, :waiting_selection] => :ready
    end
  end
end
