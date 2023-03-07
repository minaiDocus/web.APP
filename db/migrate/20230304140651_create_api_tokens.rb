class CreateApiTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :api_tokens do |t|
      t.references :organization, index: true, foreign_key: false
      t.string :token

      t.timestamps
    end
  end
end
