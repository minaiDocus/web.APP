class AddPeriodV2ToPeriodDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :period_documents, :period_v2, :integer, default: 0, null: false
  end
end
