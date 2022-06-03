class AddColumnToPeriodDocument < ActiveRecord::Migration[5.2]
  def change
    add_column :period_documents, :preseizures_pieces, :integer, default: 0
    add_column :period_documents, :expenses_pieces, :integer, default: 0
    add_column :period_documents, :preseizures_operations, :integer, default: 0
  end
end
