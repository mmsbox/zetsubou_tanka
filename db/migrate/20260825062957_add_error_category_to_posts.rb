class AddErrorCategoryToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :error_category, :string
  end
end
