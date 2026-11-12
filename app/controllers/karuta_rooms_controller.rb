class KarutaRoomsController < ApplicationController
  before_action :authenticate_user!

  # 部屋を作る
  def create
    room = KarutaRoom.open!(current_user)
    redirect_to karuta_room_path(room.code)
  rescue KarutaRoom::NotEnoughCards
    redirect_to karuta_path, alert: "札にできる短歌が足りず、部屋を開けませぬ。"
  end

  # 合言葉の入力フォームから部屋へ
  def join
    code = KarutaRoom.normalize_code(params[:code])
    if code.blank?
      redirect_to karuta_path, alert: "合言葉を入力してくだされ。"
    else
      redirect_to karuta_room_path(code)
    end
  end

  # 部屋（入室も兼ねる）
  def show
    @room = KarutaRoom.active.find_by(code: KarutaRoom.normalize_code(params[:code]))
    return redirect_to(karuta_path, alert: "その合言葉の部屋は見つかりませぬ（期限切れの可能性があります）。") unless @room

    @role, newly_joined = @room.join!(current_user)
    return redirect_to(karuta_path, alert: "その部屋はすでに満席でございます。") unless @role

    KarutaRoomChannel.broadcast_to(@room, { event: "joined", state: @room.public_state }) if newly_joined
  end
end
