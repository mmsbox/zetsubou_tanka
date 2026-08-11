class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockout, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :posts, dependent: :nullify # ユーザーが削除されても投稿は残す（または :destroy）
end
