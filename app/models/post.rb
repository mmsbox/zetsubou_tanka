class Post < ApplicationRecord
  belongs_to :user, optional: true

  # 返歌用の自己参照リレーション
  belongs_to :parent, class_name: "Post", optional: true
  has_many :replies, class_name: "Post", foreign_key: "parent_id", dependent: :destroy

  validates :error_message, presence: true

  # 🏷️ エラーカテゴリの定義
  CATEGORIES = %w[SyntaxError NullPointer 環境構築 本番DB事故 タイポ 無限ループ その他].freeze

  # 🏷️ 絞り込み用スコープ
  scope :by_category, ->(category) { where(error_category: category) if category.present? }

  # ソート用スコープ
  scope :latest, -> { reorder(created_at: :desc) }
  # likes_count が nil の場合も 0 として安全に降順ソート
  scope :most_liked, -> { reorder(Arel.sql("COALESCE(likes_count, 0) DESC, created_at DESC")) }
end
