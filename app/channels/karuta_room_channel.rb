# 🎴 合言葉の部屋のリアルタイム通信。審判は KarutaRoom が行い、ここは中継のみ
class KarutaRoomChannel < ApplicationCable::Channel
  def subscribed
    room = KarutaRoom.active.find_by(code: params[:code])
    return reject unless room&.role_of(current_user)

    @room_id = room.id
    @role = room.role_of(current_user)
    stream_for room
    room.touch_presence!(current_user)
    broadcast_presence(online: true)
  end

  def unsubscribed
    broadcast_presence(online: false) if @room_id
  end

  # 対局中、各ブラウザから定期的に届く「まだ接続している」合図
  def heartbeat
    room.touch_presence!(current_user)
  end

  # 相手が戻らないときの不戦勝の申し立て。まだ相手が居るなら、その旨を申し立てた本人にだけ返す
  def claim_forfeit
    event = room.claim_forfeit!(current_user)
    if event
      publish(event)
    else
      transmit({ event: "presence", role: @role == "host" ? "guest" : "host", online: true, state: room.public_state })
    end
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

  def broadcast_presence(online:)
    self.class.broadcast_to(room, { event: "presence", role: @role, online: online, state: room.public_state })
  end

  def publish(event)
    self.class.broadcast_to(room, event) if event
  end
end
