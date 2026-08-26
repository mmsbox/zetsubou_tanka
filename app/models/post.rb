class Post < ApplicationRecord
  belongs_to :user, optional: true

  # 返歌用の自己参照リレーション
  belongs_to :parent, class_name: "Post", optional: true
  has_many :replies, class_name: "Post", foreign_key: "parent_id", dependent: :destroy

  # 必達チェック：短歌本文かエラーメッセージのどちらかが存在すること
  validates :tanka, presence: true, if: -> { error_message.blank? }
  validates :error_message, presence: true, if: -> { tanka.blank? }

  # 🏷️ グループ別エラー・タグ定義
  CATEGORY_GROUPS = {
    "🏫 RUNTEQ生活" => %w[カリキュラム詰まり 学習記録 入学直後 卒業制作 転職活動 仲間募集],
    "💻 エラー種別" => %w[SyntaxError NullPointer NoMethodError UndefinedVariable 型エラー API連携バグ],
    "⚙️ 環境・DB" => %w[環境構築 Docker事故 本番DB事故 マイグレーション Gem依存関係],
    "🔥 人為的ミス" => %w[タイポ 無限ループ Git事故 誤コミット 仕様見落とし]
  }.freeze

  # 全タグの一覧リスト
  ALL_CATEGORIES = CATEGORY_GROUPS.values.flatten.freeze

  # 🏷️ 絞り込み用スコープ
  scope :by_category, ->(category) { where(error_category: category) if category.present? }

  # ソート用スコープ
  scope :latest, -> { reorder(created_at: :desc) }
  scope :most_liked, -> { reorder(Arel.sql("COALESCE(likes_count, 0) DESC, created_at DESC")) }
end
