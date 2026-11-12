class CreateKarutaResults < ActiveRecord::Migration[8.1]
  def change
    create_table :karuta_results do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.string :level, null: false
      t.integer :player_score, null: false, default: 0
      t.integer :cpu_score, null: false, default: 0
      t.integer :otetsuki, null: false, default: 0
      t.integer :card_count, null: false

      t.timestamps
    end
    add_index :karuta_results, [ :user_id, :created_at ]
  end
end
