require "test_helper"

class SecurityHardeningTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @own_post = Post.create!(user: @user, tanka: "あ い う え お", error_message: "自作短歌")
  end

  test "投稿時に共感数（likes_count）は受け取らない" do
    sign_in @user

    post posts_url, params: { post: { tanka: "あ い う え お", likes_count: 9999 } }

    assert_equal 0, Post.order(:id).last.likes_count.to_i
  end

  test "推敲時に共感数と返歌の宛先は変えられない" do
    sign_in @user
    other = posts(:two)

    patch post_url(@own_post), params: { post: { tanka: "か き く け こ", likes_count: 9999, parent_id: other.id } }

    @own_post.reload
    assert_equal "か き く け こ", @own_post.tanka
    assert_equal 0, @own_post.likes_count.to_i
    assert_nil @own_post.parent_id
  end

  test "他人の短歌は推敲・削除できない" do
    sign_in users(:two)

    patch post_url(@own_post), params: { post: { tanka: "のっとり" } }
    assert_redirected_to mypage_path
    assert_equal "あ い う え お", @own_post.reload.tanka

    assert_no_difference("Post.count") { delete post_url(@own_post) }
  end

  test "存在しない短歌への返歌は保存しない" do
    sign_in @user

    assert_no_difference("Post.count") do
      post posts_url, params: { post: { tanka: "あ い う え お", parent_id: 0 } }
    end
    assert_response :unprocessable_entity
  end

  test "長すぎるエラーログはAIに送らず保存しない" do
    sign_in @user

    assert_no_difference("Post.count") do
      post posts_url, params: { post: { error_message: "x" * (Post::ERROR_MESSAGE_MAX_LENGTH + 1) } }
    end
    assert_response :unprocessable_entity
  end

  test "投稿の回数制限を超えると新規投稿ページへ戻す" do
    sign_in @user

    10.times { post posts_url, params: { post: { tanka: "あ い う え お" } } }
    assert_no_difference("Post.count") do
      post posts_url, params: { post: { tanka: "あ い う え お" } }
    end
    assert_redirected_to new_post_path
  end

  test "ログインの回数制限を超えるとトップへ戻す" do
    10.times { post user_session_url, params: { user: { email: "user1@example.com", password: "wrong" } } }

    post user_session_url, params: { user: { email: "user1@example.com", password: "password" } }
    assert_redirected_to root_path
    assert_nil controller.current_user
  end

  test "「わかる」の回数制限を超えると429を返す" do
    30.times { post like_post_url(@own_post), as: :json }

    post like_post_url(@own_post), as: :json
    assert_response :too_many_requests
  end
end
