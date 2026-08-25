class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockout, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :posts, dependent: :nullify # ユーザーが削除されても投稿は残す

  # 👑 ユーザーの総獲得共感数（いいね数）の計算
  def total_likes_count
    posts.sum("COALESCE(likes_count, 0)")
  end

  # 🏅 称号ランク（絶望度バッジ）の判定
  def despair_rank
    p_count = posts.count
    l_count = total_likes_count

    if p_count >= 50 || l_count >= 100
      { title: "絶望の神", icon: "👑", color: "#ffd700", bg_rgba: "rgba(255, 215, 0, 0.15)", border: "#ffd700" }
    elsif p_count >= 20 || l_count >= 50
      { title: "終焉の歌聖", icon: "🕯️", color: "#e5c158", bg_rgba: "rgba(229, 193, 88, 0.15)", border: "#e5c158" }
    elsif p_count >= 10 || l_count >= 30
      { title: "悲哀の錬金術師", icon: "🥀", color: "#ff79c6", bg_rgba: "rgba(255, 121, 198, 0.15)", border: "#ff79c6" }
    elsif p_count >= 5 || l_count >= 10
      { title: "漆黒の詠み手", icon: "🌑", color: "#bd93f9", bg_rgba: "rgba(189, 147, 249, 0.15)", border: "#bd93f9" }
    elsif p_count >= 1
      { title: "絶望の見習い", icon: "🌱", color: "#50fa7b", bg_rgba: "rgba(80, 250, 123, 0.15)", border: "#50fa7b" }
    else
      { title: "迷える魂", icon: "👻", color: "#a39382", bg_rgba: "rgba(163, 147, 130, 0.15)", border: "#5a4a3e" }
    end
  end
end
