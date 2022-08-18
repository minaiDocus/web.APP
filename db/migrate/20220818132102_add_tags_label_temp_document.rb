class AddTagsLabelTempDocument < ActiveRecord::Migration[5.2]
  def change
    add_column :temp_documents, :tags, :text, after: :original_file_name
    add_column :temp_documents, :label, :string, after: :original_file_name
  end
end
