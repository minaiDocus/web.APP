class CreateColumnToAccountingPlanItem < ActiveRecord::Migration[5.2]
  def change
    add_column :accounting_plan_items, :vat_not_recoverable, :boolean, default: false, after: :is_updated
  end
end
