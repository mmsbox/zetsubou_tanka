require "test_helper"

class TankaMoraTest < ActiveSupport::TestCase
  test "ひらがなは1文字1音で数える" do
    assert_equal 5, TankaMora.count("あきらめて")
  end

  test "促音「っ」は1音として数える" do
    assert_equal 3, TankaMora.count("きっと")
    assert_equal 7, TankaMora.count("やっぱりきえた")
  end

  test "長音「ー」は1音として数える" do
    assert_equal 3, TankaMora.count("えらー")
    assert_equal 5, TankaMora.count("こんぴゅーた")
  end

  test "拗音（ゃゅょ）や小書きの母音は前の文字と合わせて1音" do
    assert_equal 2, TankaMora.count("きょう")
    assert_equal 3, TankaMora.count("ふぁいる")
  end

  test "カタカナはひらがなと同じように数える" do
    assert_equal 3, TankaMora.count("エラー")
    assert_equal 3, TankaMora.count("キョウト")
  end

  test "空白・記号・英数字・漢字は数えない" do
    assert_equal 5, TankaMora.count("あき らめ、て!")
    assert_equal 2, TankaMora.count("nil にる")
    assert_equal 0, TankaMora.count(nil)
  end
end
