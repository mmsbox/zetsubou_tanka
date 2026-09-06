require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  # Deviseのログインヘルパー（sign_in）を有効化
  include Devise::Test::IntegrationHelpers

  test "should get new" do
    # テスト用ユーザーでログイン
    user = users(:one)
    sign_in user

    get new_post_url
    assert_response :success
  end
end
