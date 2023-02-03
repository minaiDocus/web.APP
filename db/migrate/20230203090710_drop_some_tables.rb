class DropSomeTables < ActiveRecord::Migration[5.2]
  def change
    drop_table :archive_budgea_users
    drop_table :archive_retrievers
    drop_table :archive_webhook_contents
    drop_table :compositions
    drop_table :exercices
    drop_table :new_provider_requests
    drop_table :ibiza
    drop_table :knowings
    drop_table :new_provider_requests
  end
end
