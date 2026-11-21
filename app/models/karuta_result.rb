class KarutaResult < ApplicationRecord
  belongs_to :user

  # 🎴 対戦相手（難易度）のキーと表示名。JS側の LEVELS と対応
  LEVELS = {
    "minarai" => "見習い法師",
    "kasei" => "歌聖法師",
    "kami" => "絶望の神"
  }.freeze

  validates :level, inclusion: { in: LEVELS.keys }
  validates :card_count, numericality: {
    only_integer: true,
    greater_than_or_equal_to: Post::KARUTA_MIN_CARDS,
    less_than_or_equal_to: Post::KARUTA_ROUND_SIZE
  }
  validates :player_score, :cpu_score, :otetsuki, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :scores_must_match_card_count

  scope :recent, -> { order(created_at: :desc) }

  # 📊 戦績の集計（全体と難易度別）
  def self.stats
    empty = -> { { total: 0, wins: 0, losses: 0, draws: 0 } }
    result = { by_level: LEVELS.keys.index_with { empty.call } }.merge(empty.call)

    pluck(:level, :player_score, :cpu_score).each do |level, player, cpu|
      key = if player > cpu then :wins elsif player < cpu then :losses else :draws end
      [ result, result[:by_level][level] ].compact.each do |bucket|
        bucket[:total] += 1
        bucket[key] += 1
      end
    end

    result
  end

  def outcome
    if player_score > cpu_score then :win
    elsif player_score < cpu_score then :lose
    else :draw
    end
  end

  def outcome_label
    { win: "🏆 勝利", lose: "💀 敗北", draw: "🤝 引き分け" }[outcome]
  end

  def level_name
    LEVELS[level]
  end

  private

  # 札は必ずどちらかが1枚ずつ取る。法師の点にはお手つきの献上分が含まれる
  def scores_must_match_card_count
    return if [ player_score, cpu_score, otetsuki, card_count ].any? { |v| !v.is_a?(Integer) }
    return if otetsuki <= cpu_score && player_score + cpu_score - otetsuki == card_count

    errors.add(:base, "点数と札の枚数が合いませぬ")
  end
end
