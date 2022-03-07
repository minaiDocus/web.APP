class CreateTicket < ActiveRecord::Migration[5.2]
  def change
    create_table :tickets do |t|
      t.integer :user_id
      t.integer :priority, default: 0
      t.string :title
      t.string :state
      t.string :closed_by
      t.string :created_by
      t.string :category
      t.text :content
      t.date :closed_date
      t.date :reopen_date

      t.timestamps
    end
  end
end
