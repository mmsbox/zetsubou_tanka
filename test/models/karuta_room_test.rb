require "test_helper"

class KarutaRoomTest < ActiveSupport::TestCase
  setup do
    phrases = %w[あかさたな いきしちにひみ うくすつぬ えけせてねへめ おこそとのほも]
    4.times { |i| Post.create!(error_message: "Error #{i}", tanka: phrases.map { |p| "#{p}#{i}" }.join(" ")) }
    @host = users(:one)
    @guest = users(:two)
    @room = KarutaRoom.open!(@host)
  end

  def current_id
    @room.reload.reading_order[@room.turn - 1]
  end

  def wrong_id
    (@room.reload.reading_order - [ current_id ] - @room.taken.keys.map(&:to_i)).first
  end

  def start_game
    @room.join!(@guest)
    @room.start!(@host)
  end

  test "部屋を作ると合言葉と札が用意される" do
    assert_match(/\A[A-Z2-9]{6}\z/, @room.code)
    assert_match(/\A(#{Post::ALL_CATEGORIES.map { Regexp.escape(_1) }.join("|")})(#{KarutaRoom::ROOM_SUFFIXES.join("|")})\z/, @room.name)
    assert_equal 4, @room.cards.size
    assert_equal @room.cards.map { |c| c["id"] }.sort, @room.reading_order.sort
    assert_equal "waiting", @room.status
  end

  test "札が足りなければ部屋を作れない" do
    Post.delete_all
    assert_raises(KarutaRoom::NotEnoughCards) { KarutaRoom.open!(@host) }
  end

  test "ブラウザに渡す札には上の句を含めない" do
    assert(@room.field_cards.all? { |card| card.keys.sort == %w[id shimo] })
  end

  test "主・客・満席の入室" do
    assert_equal [ "host", false ], @room.join!(@host)
    assert_equal [ "guest", true ], @room.join!(@guest)
    assert_equal [ "guest", false ], @room.join!(@guest)
    stranger = User.create!(email: "stranger@example.com", password: "password")
    assert_equal [ nil, false ], @room.join!(stranger)
  end

  test "客がいなければ始められず、主だけが始められる" do
    assert_nil @room.start!(@host)
    @room.join!(@guest)
    assert_nil @room.start!(@guest)

    event = @room.start!(@host)
    assert_equal "turn", event[:event]
    assert_equal 1, event[:turn]
    assert_equal "playing", @room.reload.status
  end

  test "正しい札を先に取った方だけが得点する" do
    start_game
    id = current_id

    events = @room.take!(@guest, id, 1)
    assert_equal "taken", events.first[:event]
    assert_equal "guest", events.first[:by]
    assert_equal 1, @room.reload.guest_score

    # 同じ首への遅れた取りは無効
    assert_empty @room.take!(@host, id, 1)
    assert_equal 0, @room.reload.host_score
  end

  test "お手つきは相手に1点、両者お手つきなら札は流れる" do
    start_game

    events = @room.take!(@host, wrong_id, 1)
    assert_equal "otetsuki", events.first[:event]
    assert_not events.first[:nagare]
    assert_equal [ 0, 1, 1 ], @room.reload.values_at(:host_score, :guest_score, :host_otetsuki)

    # お手つきした首にはもう手を出せない
    assert_empty @room.take!(@host, current_id, 1)

    events = @room.take!(@guest, wrong_id, 1)
    assert events.first[:nagare]
    assert_equal "none", @room.reload.taken[current_id.to_s]
    assert_not @room.turn_open
  end

  test "次の首へは1回だけ進み、全首終われば終局する" do
    start_game

    4.times do |i|
      turn = i + 1
      @room.take!(@host, current_id, turn)
      assert @room.advance!(turn)
      assert_nil @room.advance!(turn), "同じ首からの二重の進行は無視される"
    end

    assert_equal "finished", @room.reload.status
    assert_equal 4, @room.host_score
  end

  test "古い首の番号で取ろうとしても無効" do
    start_game
    assert_empty @room.take!(@host, current_id, 2)
  end
end
