require "test_helper"

class MypagesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should get show" do
    user = users(:one)
    sign_in user

    get mypage_url
    assert_response :success
  end
end
