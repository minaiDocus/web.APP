class DropColumn < ActiveRecord::Migration[5.2]
  def change
    remove_column :account_book_types, :vat_account
    remove_column :account_book_types, :vat_account_10
    remove_column :account_book_types, :vat_account_8_5
    remove_column :account_book_types, :vat_account_5_5
    remove_column :account_book_types, :vat_account_2_1

    remove_column :mcf_documents, :file64

    remove_column :organizations, :is_quadratus_used
    remove_column :organizations, :is_quadratus_auto_deliver
    remove_column :organizations, :is_csv_descriptor_used
    remove_column :organizations, :is_csv_descriptor_auto_deliver
    remove_column :organizations, :is_coala_used
    remove_column :organizations, :is_coala_auto_deliver
    remove_column :organizations, :is_exact_online_used
    remove_column :organizations, :is_exact_online_auto_deliver
    remove_column :organizations, :is_cegid_used
    remove_column :organizations, :is_cegid_auto_deliver
    remove_column :organizations, :is_fec_agiris_used
    remove_column :organizations, :is_fec_agiris_auto_deliver

    remove_column :pack_report_preseizures, :is_delivered
    remove_column :pack_report_preseizures, :is_delivered_to

    remove_column :pack_reports, :is_delivered
    remove_column :pack_reports, :is_delivered_to

    remove_column :packs, :is_indexing

    remove_column :pre_assignment_deliveries, :data_to_deliver

    remove_column :pre_assignment_deliveries, :data_to_deliver

    remove_column :temp_documents, :fiduceo_retriever_id

    remove_column :users, :knowings_code
    remove_column :users, :knowings_visibility
    remove_column :users, :ibiza_id
    remove_column :users, :is_fiduceo_authorized
    remove_column :users, :current_configuration_step
    remove_column :users, :last_configuration_step
  end
end
