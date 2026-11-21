require "test_helper"

class MypagesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should get show" do
    user = users(:one)
    sign_in user

    get mypage_url
    assert_response :success
  end

  test "かるた戦績タブに対局結果と称号を表示する" do
    user = users(:one)
    user.karuta_results.create!(level: "kasei", player_score: 6, cpu_score: 2, otetsuki: 0, card_count: 8)
    sign_in user

    get mypage_url
    assert_response :success
    assert_match "札取りの若武者", response.body
    assert_match "vs 歌聖法師", response.body
  end

  test "かるた戦績タブに対人戦の結果を表示する" do
    phrases = %w[あかさたな いきしちにひみ うくすつぬ えけせてねへめ おこそとのほも]
    4.times { |i| Post.create!(error_message: "Error #{i}", tanka: phrases.map { |p| "#{p}#{i}" }.join(" ")) }
    room = KarutaRoom.open!(users(:one))
    room.join!(users(:two))
    room.start!(users(:one))
    room.update_column(:guest_seen_at, 1.minute.ago)
    room.claim_forfeit!(users(:one))
    sign_in users(:one)

    get mypage_url
    assert_response :success
    assert_match "対人戦（合言葉の部屋）", response.body
    assert_match "不戦勝", response.body
    assert_match "vs テスト法師二号", response.body
  end
end
