require "test_helper"

class KarutaResultTest < ActiveSupport::TestCase
  def build_result(**attrs)
    users(:one).karuta_results.build({ level: "kasei", player_score: 5, cpu_score: 4, otetsuki: 1, card_count: 8 }.merge(attrs))
  end

  test "点数と札の枚数が合っていれば保存できる" do
    assert build_result.valid?
  end

  test "点数の合計が札の枚数と合わなければ無効" do
    assert_not build_result(player_score: 8).valid?
  end

  test "お手つきが法師の点を超えていれば無効" do
    assert_not build_result(player_score: 8, cpu_score: 0, otetsuki: 1).valid?
  end

  test "存在しない難易度は無効" do
    assert_not build_result(level: "oni").valid?
  end

  test "札の枚数が1局の上限を超えていれば無効" do
    assert_not build_result(player_score: 100, cpu_score: 1, otetsuki: 1, card_count: 100).valid?
  end

  test "stats は勝敗を全体と難易度別に集計する" do
    user = users(:one)
    user.karuta_results.create!(level: "kasei", player_score: 6, cpu_score: 2, otetsuki: 0, card_count: 8)
    user.karuta_results.create!(level: "kami", player_score: 2, cpu_score: 6, otetsuki: 0, card_count: 8)
    user.karuta_results.create!(level: "kami", player_score: 4, cpu_score: 4, otetsuki: 0, card_count: 8)

    stats = user.karuta_results.stats
    assert_equal({ total: 3, wins: 1, losses: 1, draws: 1 }, stats.except(:by_level))
    assert_equal({ total: 2, wins: 0, losses: 1, draws: 1 }, stats[:by_level]["kami"])
    assert_equal 0, stats[:by_level]["minarai"][:total]
  end

  test "karuta_rank は勝ち方に応じて称号が上がる" do
    user = users(:one)
    assert_nil user.karuta_rank

    user.karuta_results.create!(level: "minarai", player_score: 2, cpu_score: 6, otetsuki: 0, card_count: 8)
    assert_equal "かるた初陣", user.karuta_rank[:title]

    user.karuta_results.create!(level: "minarai", player_score: 6, cpu_score: 2, otetsuki: 0, card_count: 8)
    assert_equal "札取りの若武者", user.karuta_rank[:title]

    user.karuta_results.create!(level: "kami", player_score: 5, cpu_score: 3, otetsuki: 0, card_count: 8)
    assert_equal "神をも退けし名人", user.karuta_rank[:title]
  end
end
