class CreateKarutaRooms < ActiveRecord::Migration[8.1]
  def change
    create_table :karuta_rooms do |t|
      t.string :code, null: false
      t.references :host, null: false, foreign_key: { to_table: :users }
      t.references :guest, foreign_key: { to_table: :users }
      t.string :status, null: false, default: "waiting"
      t.jsonb :cards, null: false, default: []
      t.jsonb :reading_order, null: false, default: []
      t.integer :turn, null: false, default: 0
      t.boolean :turn_open, null: false, default: false
      t.jsonb :missed, null: false, default: []
      t.jsonb :taken, null: false, default: {}
      t.integer :host_score, null: false, default: 0
      t.integer :guest_score, null: false, default: 0
      t.integer :host_otetsuki, null: false, default: 0
      t.integer :guest_otetsuki, null: false, default: 0

      t.timestamps
    end
    add_index :karuta_rooms, :code, unique: true
  end
end
