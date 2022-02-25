class AddColumnToPeriod < ActiveRecord::Migration[5.2]
  def change
    add_column :periods, :basic_excess, :integer, default: 0
    add_column :periods, :basic_total_compta_piece, :integer, default: 0

    add_column :periods, :plus_micro_excess, :integer, default: 0
    add_column :periods, :plus_micro_total_compta_piece, :integer, default: 0
  end
end
