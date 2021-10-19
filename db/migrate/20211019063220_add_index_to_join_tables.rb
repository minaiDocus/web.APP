class AddIndexToJoinTables < ActiveRecord::Migration[5.2]
  def change
    add_index :pack_report_preseizures_pre_assignment_deliveries, :pre_assignment_delivery_id, name: 'index_prppad_pre_assignment_delivery_id'
    add_index :pack_report_preseizures_pre_assignment_deliveries, :preseizure_id, name: 'index_prppad_preseizure_id'

    add_index :pack_report_preseizures_pre_assignment_exports, :preseizure_id, name: 'index_prppae_preseizure_id'
    add_index :pack_report_preseizures_pre_assignment_exports, :pre_assignment_export_id, name: 'index_prppae_pre_assignment_export_id'

    add_index :pack_report_preseizures_remote_files, :remote_file_id, name: 'index_prprf_remote_file_id'
    add_index :pack_report_preseizures_remote_files, :pack_report_preseizure_id, name: 'index_prprf_pack_report_preseizure_id'

    add_index :subscription_options_subscriptions, :subscription_id, name: 'index_sos_subscription_id'
    add_index :subscription_options_subscriptions, :subscription_option_id, name: 'index_sos_subscription_option_id'

    add_index :organization_groups_organizations, :organization_id, name: 'index_ogo_organization_id'
    add_index :organization_groups_organizations, :organization_group_id, name: 'index_ogo_organization_group_id'

    add_index :account_number_rules_users, :user_id, name: 'index_anru_user_id'
    add_index :account_number_rules_users, :account_number_rule_id, name: 'index_anru_account_number_rule_id'
  end
end
