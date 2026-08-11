class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.string :author_name
      t.text :error_message
      t.text :tanka
      t.integer :likes_count

      t.timestamps
    end
  end
end
