require "test_helper"

class KarutaRoomsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    phrases = %w[あかさたな いきしちにひみ うくすつぬ えけせてねへめ おこそとのほも]
    4.times { |i| Post.create!(error_message: "Error #{i}", tanka: phrases.map { |p| "#{p}#{i}" }.join(" ")) }
  end

  test "部屋を作ると部屋のページへ移る" do
    sign_in users(:one)

    assert_difference -> { KarutaRoom.count }, 1 do
      post karuta_rooms_url
    end
    room = KarutaRoom.last
    assert_redirected_to karuta_room_path(room.code)

    get karuta_room_url(room.code)
    assert_response :success
    assert_select "[data-karuta-room-role-value='host']"
  end

  test "札が足りなければ部屋を作れない" do
    Post.delete_all
    sign_in users(:one)

    post karuta_rooms_url
    assert_redirected_to karuta_path
  end

  test "合言葉（小文字でも可）で客として入室できる" do
    room = KarutaRoom.open!(users(:one))
    sign_in users(:two)

    get join_karuta_room_url, params: { code: room.code.downcase }
    assert_redirected_to karuta_room_path(room.code)

    get karuta_room_url(room.code)
    assert_response :success
    assert_select "[data-karuta-room-role-value='guest']"
    assert_equal users(:two), room.reload.guest
  end

  test "満席の部屋には入れない" do
    room = KarutaRoom.open!(users(:one))
    room.join!(users(:two))
    sign_in User.create!(email: "stranger@example.com", password: "password")

    get karuta_room_url(room.code)
    assert_redirected_to karuta_path
  end

  test "存在しない合言葉は案内してかるたへ戻す" do
    sign_in users(:one)
    get karuta_room_url("ZZZZZZ")
    assert_redirected_to karuta_path
  end

  test "未ログインではログイン画面へ" do
    post karuta_rooms_url
    assert_redirected_to new_user_session_path
  end
end
