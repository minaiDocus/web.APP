class AddDeliveryAndExportStateToPreseizure < ActiveRecord::Migration[5.2]
  def change
    add_column :pack_report_preseizures, :delivery_state, :string, default: 'not_configured', after: :is_delivered
    add_column :pack_report_preseizures, :export_state, :string, default: 'not_configured', after: :is_delivered

    add_index  :pack_report_preseizures, :delivery_state
    add_index  :pack_report_preseizures, :export_state
  end
end
