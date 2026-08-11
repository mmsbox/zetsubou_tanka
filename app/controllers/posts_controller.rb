class PostsController < ApplicationController
  def index
    # 新しい投稿順（降順）に全件取得
    @posts = Post.all.order(created_at: :desc)
  end

  def new
    # フォーム用の空のPostインスタンスを作成
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    if @post.save
      # 保存成功したら一覧画面へリダイレクト
      redirect_to posts_path, notice: "投稿が完了しました！"
    else
      # 保存失敗したら新規作成画面を再描画
      render :new, status: :unprocessable_entity
    end
  end

  private

  # Strong Parameters（安全にデータを保存するためのフィルタ）
  def post_params
    params.require(:post).permit(:error_message, :tanka, :likes_count)
    end

 end
