require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "karuta_card は短歌を上の句と下の句に分ける（全角スペース区切りにも対応）" do
    post = Post.new(id: 1, tanka: "消えたコード　二度と戻らぬ　黄昏に 静かに閉じる エディタの画面", author_name: "テスト法師")

    card = post.karuta_card
    assert_equal %w[消えたコード 二度と戻らぬ 黄昏に], card[:kami]
    assert_equal %w[静かに閉じる エディタの画面], card[:shimo]
    assert_equal "テスト法師", card[:author]
  end

  test "karuta_card は5句に分かれていない短歌では nil を返す" do
    assert_nil Post.new(tanka: "区切りのない短歌").karuta_card
  end

  test "karuta_deck は札にできない歌と下の句の重複を除外する" do
    Post.delete_all
    Post.create!(error_message: "e", tanka: "あ い う え お", likes_count: 3)
    Post.create!(error_message: "e", tanka: "か き く え お", likes_count: 2) # 下の句が重複
    Post.create!(error_message: "e", tanka: "区切りなし", likes_count: 1)

    deck = Post.karuta_deck
    assert_equal 1, deck.size
    assert_equal %w[あ い う], deck.first[:kami]
  end
end
