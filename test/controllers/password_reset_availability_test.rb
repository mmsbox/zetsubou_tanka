require "test_helper"

class PasswordResetAvailabilityTest < ActionDispatch::IntegrationTest
  test "メール送信が使える環境ではログイン画面に再設定リンクを出す" do
    get new_user_session_url
    assert_response :success
    assert_select "a[href='#{new_user_password_path}']"
  end

  test "メール未設定なら再設定リンクを隠し、再設定ページも閉じる" do
    Rails.configuration.x.password_reset_available = false

    get new_user_session_url
    assert_response :success
    assert_select "a[href='#{new_user_password_path}']", count: 0

    get new_user_password_url
    assert_redirected_to new_user_session_path
  ensure
    Rails.configuration.x.password_reset_available = true
  end
end
