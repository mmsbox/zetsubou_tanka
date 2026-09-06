require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should get index" do
    get posts_url
    assert_response :success
  end

  test "should get new" do
    user = users(:one)
    sign_in user

    get new_post_url
    assert_response :success
  end
end
