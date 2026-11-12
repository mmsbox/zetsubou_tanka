require "test_helper"

class KarutaRoomChannelTest < ActionCable::Channel::TestCase
  setup do
    phrases = %w[あかさたな いきしちにひみ うくすつぬ えけせてねへめ おこそとのほも]
    4.times { |i| Post.create!(error_message: "Error #{i}", tanka: phrases.map { |p| "#{p}#{i}" }.join(" ")) }
    @room = KarutaRoom.open!(users(:one))
    @room.join!(users(:two))
  end

  test "部屋の参加者は購読できる" do
    stub_connection current_user: users(:one)
    subscribe code: @room.code

    assert subscription.confirmed?
    assert_has_stream_for @room
  end

  test "部外者は購読できない" do
    stub_connection current_user: User.create!(email: "stranger@example.com", password: "password")
    subscribe code: @room.code

    assert subscription.rejected?
  end

  test "主が開始すると第1首のイベントが部屋に配信される" do
    stub_connection current_user: users(:one)
    subscribe code: @room.code

    stream = KarutaRoomChannel.broadcasting_for(@room)
    assert_broadcasts(stream, 1) { perform :start }

    message = ActiveSupport::JSON.decode(broadcasts(stream).last)
    assert_equal "turn", message["event"]
    assert_equal 1, message["turn"]
  end

  test "札を取るとイベントが部屋に配信される" do
    stub_connection current_user: users(:two)
    subscribe code: @room.code
    @room.start!(users(:one))
    current_id = @room.reload.reading_order.first

    assert_broadcasts(KarutaRoomChannel.broadcasting_for(@room), 1) do
      perform :take, card_id: current_id, turn: 1
    end
    assert_equal 1, @room.reload.guest_score
  end

  test "購読すると接続を記録し、入室を部屋に知らせる" do
    stub_connection current_user: users(:two)

    assert_broadcasts(KarutaRoomChannel.broadcasting_for(@room), 1) do
      subscribe code: @room.code
    end
    assert_not_nil @room.reload.guest_seen_at
  end

  test "相手がまだ居るときの不戦勝の申し立ては、本人にだけ相手の在室を返す" do
    @room.start!(users(:one))
    @room.touch_presence!(users(:two))
    stub_connection current_user: users(:one)
    subscribe code: @room.code

    assert_no_broadcasts(KarutaRoomChannel.broadcasting_for(@room)) do
      perform :claim_forfeit
    end
    assert_equal "presence", transmissions.last["event"]
    assert transmissions.last["online"]
    assert_equal "playing", @room.reload.status
  end
end
