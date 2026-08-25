class AddParentIdToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :parent_id, :integer
    add_index :posts, :parent_id
  end
end
