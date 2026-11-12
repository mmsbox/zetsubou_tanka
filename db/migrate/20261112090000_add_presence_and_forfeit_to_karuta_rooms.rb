class AddPresenceAndForfeitToKarutaRooms < ActiveRecord::Migration[8.1]
  def change
    add_column :karuta_rooms, :host_seen_at, :datetime
    add_column :karuta_rooms, :guest_seen_at, :datetime
    add_column :karuta_rooms, :forfeit_by, :string # 途中で抜けて不戦敗になった側（host / guest）
    add_index :karuta_rooms, :status
  end
end
