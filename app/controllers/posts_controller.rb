class PostsController < ApplicationController
  def index
    @sort = params[:sort] || "latest"

    @posts = case @sort
             when "likes"
               Post.order(likes_count: :desc, created_at: :desc)
             else
               Post.order(created_at: :desc)
             end
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    if @post.save
      redirect_to @post, notice: "短歌が詠まれました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # POST /posts/:id/like
  def like
    @post = Post.find(params[:id])
    # 確実にlikes_countをインクリメント
    current = @post.likes_count || 0
    @post.update_columns(likes_count: current + 1)

    Rails.logger.info("==========================================")
    Rails.logger.info("Post ID:#{@post.id} likes_count updated to #{@post.likes_count}")
    Rails.logger.info("==========================================")

    render json: { success: true, likes_count: @post.likes_count }
  rescue StandardError => e
    Rails.logger.error("Like Action Error: #{e.message}")
    render json: { success: false, error: e.message }, status: :internal_server_error
  end

  def ogp
    @post = Post.find(params[:id])
    tanka_text = @post.tanka.presence || "エラー吐き 詠めぬ短歌の 虚しさよ"
    author_text = "詠み手：#{@post.author_name.presence || '名無し法師'}"

    image = ImageProcessing::MiniMagick
              .source(MiniMagick::Image.create { |f| f.write "blank.png" }.tap do |img|
                img.combine_options do |c|
                  c.size "1200x630"
                  c.canvas "#1c1917"
                end
              end.path)
              .fill("#faf6ed")
              .font("Noto-Sans-CJK-JP-Bold")
              .pointsize(38)
              .gravity("center")
              .draw("text 0,-30 '#{tanka_text}'")
              .fill("#8c1d1d")
              .pointsize(24)
              .draw("text 0,150 '#{author_text}'")
              .call

    send_file image.path, type: "image/png", disposition: "inline"
  rescue StandardError => e
    Rails.logger.error("OGP Generation Error: #{e.message}")
    head :internal_server_error
  end

  private

  def post_params
    params.require(:post).permit(:tanka, :error_message, :author_name, :despair_level)
  end
end
