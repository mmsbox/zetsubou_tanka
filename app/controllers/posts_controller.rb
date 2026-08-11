class PostsController < ApplicationController
  def index
    @posts = Post.all.order(created_at: :desc)
  end

  # 結果画面（詳細表示）
  def show
    @post = Post.find(params[:id])
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)

    # ログイン中ならユーザーを紐付け
    @post.user = current_user if user_signed_in?

    # エラーメッセージがあれば OpenAI で短歌を生成
    if @post.error_message.present?
      @post.tanka = generate_tanka_from_error(@post.error_message)
    end

    # 保存処理（1回だけ！）
    if @post.save
      redirect_to post_path(@post), notice: "短歌が詠まれました！"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def post_params
    params.require(:post).permit(:author_name, :error_message, :tanka, :likes_count)
  end

  def generate_tanka_from_error(error_message)
    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

    prompt = <<~PROMPT
      あなたは「プログラミングのエラーに苦しむ駆け出しエンジニアの気持ちを詠む短歌名人」です。

      ユーザーからプログラミングのエラーログが入力されます。
      そのエラーの悲劇さや「あるある」を捉えて、クスッと笑える・共感できる短歌（5・7・5・7・7）を1首だけ生成してください。

      【制約事項】
      ・必ず 5・7・5・7・7 のリズムを守ってください。
      ・解説や前置き、挨拶は一切不要です。短歌のみを出力してください。
      ・短歌の句と句の間にはスペースを入れてください。

      【エラーログ】
      #{error_message}
    PROMPT

    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [{ role: "user", content: prompt }],
        temperature: 0.7
      }
    )

    response.dig("choices", 0, "message", "content")&.strip
  rescue StandardError => e
    Rails.logger.error("OpenAI API Error: #{e.message}")
    "エラー吐き 詠めぬ短歌の 虚しさよ（※AI連携でエラーが発生しました）"
  end
end
