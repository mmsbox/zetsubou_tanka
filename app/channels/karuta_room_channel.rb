# 🎴 合言葉の部屋のリアルタイム通信。審判は KarutaRoom が行い、ここは中継のみ
class KarutaRoomChannel < ApplicationCable::Channel
  def subscribed
    room = KarutaRoom.active.find_by(code: params[:code])
    return reject unless room&.role_of(current_user)

    @room_id = room.id
    stream_for room
  end

  def start
    publish(room.start!(current_user))
  end

  def take(data)
    room.take!(current_user, data["card_id"].to_i, data["turn"].to_i).each { |event| publish(event) }
  end

  def advance(data)
    publish(room.advance!(data["turn"].to_i))
  end

  private

  def room
    KarutaRoom.find(@room_id)
  end

  def publish(event)
    self.class.broadcast_to(room, event) if event
  end
end
