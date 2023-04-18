class DetectedOperation < ApplicationRecord
  belongs_to :piece, class_name: "Pack::Piece", foreign_key: :pack_piece_id
end
