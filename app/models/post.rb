class Post < ApplicationRecord
  # ゲスト投稿も許可するため optional: true をつける
  belongs_to :user, optional: true

  # バリデーションなどがあればその下に記述
  validates :error_message, presence: true
end
