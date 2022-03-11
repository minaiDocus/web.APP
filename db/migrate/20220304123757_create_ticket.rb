class CreateTicket < ActiveRecord::Migration[5.2]
  def change
    create_table :tickets do |t|
      t.integer :user_id
      t.integer :assigned_to
      t.string :assigned_to_name
      t.integer :priority, default: 1
      t.string :title
      t.string :state
      t.string :closed_by      
      t.string :category
      t.text :content
      t.datetime :closed_date
      t.datetime :reopen_date

      t.timestamps
    end
  end
end
