class MypagesController < ApplicationController
  before_action :authenticate_user!

  def show
    # 1. 自分が詠んだ短歌
    @posts = current_user.posts.order(created_at: :desc)

    # 2. 自分の短歌に届いた返歌（parent_id が自分の短歌IDに含まれるもの）
    @replies = Post.where(parent_id: @posts.pluck(:id)).order(created_at: :desc)

    # 3. 🌸 共感した短歌（セッションに保持されている「わかる」を押した短歌IDから取得）
    liked_ids = session[:liked_post_ids] || []
    @liked_posts = Post.where(id: liked_ids).order(created_at: :desc)
  end
end
