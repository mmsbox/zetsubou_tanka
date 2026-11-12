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
end
