class Post < ApplicationRecord
  belongs_to :user, optional: true

  validates :error_message, presence: true

  # ソート用スコープ
  scope :latest, -> { order(created_at: :desc) }
  scope :most_liked, -> { order(likes_count: :desc, created_at: :desc) }
  # もし絶望度(despair_scoreなど)のカラムがあれば以下も有効化
  # scope :most_desperate, -> { order(despair_score: :desc, created_at: :desc) }
end
