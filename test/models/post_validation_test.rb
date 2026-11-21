require "test_helper"

class PostValidationTest < ActiveSupport::TestCase
  test "文字数の上限を超えると無効" do
    post = Post.new(tanka: "あ" * 201, error_message: "自作短歌")
    assert_not post.valid?
    assert post.errors.key?(:tanka)
  end

  test "自分自身を返歌の宛先にはできない" do
    post = posts(:one)
    post.parent_id = post.id
    assert_not post.valid?
    assert post.errors.key?(:parent_id)
  end
end
