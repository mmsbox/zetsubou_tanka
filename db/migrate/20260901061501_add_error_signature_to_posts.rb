class AddErrorSignatureToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :error_signature, :string
  end
end
