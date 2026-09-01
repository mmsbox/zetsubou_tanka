class AddAiAdviceToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :ai_advice, :text
  end
end
