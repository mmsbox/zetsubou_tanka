class AddAiAdviceToPosts < ActiveRecord::Migration[8.1]
  # ai_advice カラムは schema.rb にだけ存在し、作成するマイグレーションが欠けていた。
  # 既にカラムがある環境（本番など）では何もしない。
  def up
    add_column :posts, :ai_advice, :text unless column_exists?(:posts, :ai_advice)
  end

  def down
    remove_column :posts, :ai_advice if column_exists?(:posts, :ai_advice)
  end
end
