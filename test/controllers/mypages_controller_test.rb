require "test_helper"

class MypagesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    # users.yml で定義したユーザーを取得してログイン
    user = users(:one)
    sign_in user

    get mypage_url
    assert_response :success
  end
end
