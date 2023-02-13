class DropSomeTables < ActiveRecord::Migration[5.2]
  def change
    drop_table :archive_budgea_users, if_exists: true
    drop_table :archive_retrievers, if_exists: true
    drop_table :archive_webhook_contents, if_exists: true
    drop_table :compositions, if_exists: true
    drop_table :exercices, if_exists: true
    drop_table :ibiza, if_exists: true
    drop_table :knowings, if_exists: true
    drop_table :new_provider_requests, if_exists: true
    drop_table :ibizas, if_exists: true
    drop_table :ibizas_old, if_exists: true
    drop_table :advanced_preseizures, if_exists: true
    drop_table :archive_temp_documents, if_exists: true
    drop_table :archive_temp_packs, if_exists: true
    drop_table :sandbox_bank_accounts, if_exists: true
    drop_table :sandbox_documents, if_exists: true
    drop_table :sandbox_operations, if_exists: true
    drop_table :pack_report_temp_preseizures, if_exists: true
  end
end
