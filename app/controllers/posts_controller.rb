class PostsController < ApplicationController
  before_action :authenticate_user!, only: [ :new, :create, :edit, :update, :destroy ]
  before_action :set_post, only: [ :show, :edit, :update, :destroy, :like ]
  before_action :authorize_user!, only: [ :edit, :update, :destroy ]

  OGP_BG_COLOR = "#0d0808".freeze
  OGP_TEXT_COLOR = "#e5c158".freeze
  OGP_AUTHOR_COLOR = "#a39382".freeze
  SMALL_KANA = %w[っ ゃ ゅ ょ ぁ ぃ ぅ ぇ ぉ ヮ ヵ ヶ].freeze

  def index
    @selected_category = params[:category]
    @sort_mode = params[:sort]

    # 1. カテゴリ指定があれば絞り込み（なければ全件）
    posts = Post.by_category(@selected_category)

    # 2. ソート順の適用（共感順は過去1週間の週間ランキング）
    if @sort_mode == "likes"
      @posts = posts.where("created_at >= ?", 1.week.ago).most_liked
    else
      @posts = posts.latest
    end
  end

  def show
  end

  def new
    @post = Post.new
  end

def create
    @post = Post.new(post_params)
    @post.user = current_user if respond_to?(:current_user) && current_user.present?

    # 🤖 AIモード（短歌が空でエラーメッセージがある場合）
    if @post.tanka.blank? && @post.error_message.present?
      @post.tanka = generate_tanka_from_error(@post.error_message)
    # ✍️ 自作短歌モード（短歌が入力されていて、エラーメッセージが空の場合の補填）
    elsif @post.tanka.present? && @post.error_message.blank?
      @post.error_message = "自作短歌"
    end

    if @post.save
      redirect_target = @post.parent.present? ? @post.parent : @post
      redirect_to redirect_target, notice: "短歌が詠まれました。"
    else
      Rails.logger.error("Post Save Failed: #{@post.errors.full_messages.join(', ')}")
      render :new, status: :unprocessable_entity
    end
  end
  def edit
  end

  def update
    if @post.update(post_params)
      redirect_to mypage_path, notice: "短歌を推敲（更新）しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to mypage_path, notice: "短歌を取り下げ、供養しました。"
  end

  def ogp
    post = Post.find(params[:id])

    tanka_text  = (post.tanka.presence || "エラー吐き 詠めぬ短歌の 虚しさよ").tr("\n", " ")
    author_text = "詠み手：#{post.author_name.presence || '名無し法師'}"

    image = MiniMagick::Image.create do |f|
      MiniMagick::Tool::Convert.new do |config|
        config.size "1200x630"
        config << "xc:#{OGP_BG_COLOR}"
        config << "png:#{f.path}"
      end
    end

    image.combine_options do |c|
      c.fill OGP_TEXT_COLOR
      c.pointsize "38"
      c.gravity "center"
      c.draw "text 0,-30 #{tanka_text.inspect}"
      c.fill OGP_AUTHOR_COLOR
      c.pointsize "24"
      c.draw "text 0,150 #{author_text.inspect}"
    end

    send_data image.to_blob, type: "image/png", disposition: "inline"
  rescue StandardError => e
    Rails.logger.error("OGP Generation Failure: #{e.class} - #{e.message}\n#{e.backtrace&.first(3)&.join("\n")}")

    default_image_path = Rails.root.join("app/assets/images/default_ogp.jpg")
    if File.exist?(default_image_path)
      send_file default_image_path, type: "image/jpeg", disposition: "inline"
    else
      head :internal_server_error
    end
  end

  def like
    session[:liked_post_ids] ||= []
    if session[:liked_post_ids].include?(@post.id)
      render json: { error: "すでに「わかる」を押しています", likes_count: (@post.likes_count || 0) }, status: :unprocessable_entity
      return
    end

    Post.increment_counter(:likes_count, @post.id)
    session[:liked_post_ids] << @post.id

    @post.reload
    render json: { likes_count: (@post.likes_count || 0) }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Post not found" }, status: :not_found
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def authorize_user!
    redirect_to mypage_path, alert: "権限がありません。" unless @post.respond_to?(:user) && @post.user == current_user
  end

  def post_params
    params.require(:post).permit(:author_name, :error_message, :tanka, :likes_count, :parent_id, :error_category)
  end

  def count_mora(kana)
    kana.to_s.chars.reject { |c| SMALL_KANA.include?(c) }.size
  end

  def build_tanka_prompt(error_message, feedback)
    <<~PROMPT
      あなたはプログラミングのエラーに苦しむエンジニアの悲惨さを詠む「短歌名人」です。
      入力されたエラーログをもとに、共感と絶望感が漂う短歌（5・7・5・7・7）を1首生成してください。

      #{feedback ? "【前回の音数ミスの修正指示】\n#{feedback}\nこれを踏まえて必ず正しい音数で作り直してください。\n" : ''}
      【最重要ルール：音数（モーラ数）】
      各句の「kana」（全ひらがな）の音数を厳格に守ってください。
      - ku1 (初句): 5音
      - ku2 (二句): 7音
      - ku3 (三句): 5音
      - ku4 (四句): 7音
      - ku5 (結句): 7音

      【表現のルール】
      - 毎回異なる切り口（自虐、ユーモア、情景描写、古典的な和歌風、修羅場の日常など）で表現を変えてください。
      - 定型文やありきたりな表現（「エラー吐き」「消えたコード」など）の使い回しは避け、入力されたエラーの状況に応じた具体的な言葉や比喩を使ってください。

      【出力フォーマット】
      以下のJSON形式のみを出力してください。説明文やコードブロック記号は不要です。
      各句について、漢字仮名交じりの本文(text)と、正確な読みの全ひらがな(kana)を両方出してください。
      kanaには句読点・記号を含めないでください。

      {
        "ku1": {"text": "...", "kana": "..."},
        "ku2": {"text": "...", "kana": "..."},
        "ku3": {"text": "...", "kana": "..."},
        "ku4": {"text": "...", "kana": "..."},
        "ku5": {"text": "...", "kana": "..."}
      }

      【エラーログ】
      #{error_message}
    PROMPT
  end

  def generate_tanka_from_error(error_message)
    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
    feedback = nil

    3.times do
      prompt = build_tanka_prompt(error_message, feedback)

      response = client.chat(
        parameters: {
          model: "gpt-4o-mini",
          messages: [ { role: "user", content: prompt } ],
          response_format: { type: "json_object" },
          temperature: 0.9,
          frequency_penalty: 0.5,
          presence_penalty: 0.3
        }
      )

      raw_json = response.dig("choices", 0, "message", "content")&.strip

      begin
        data = JSON.parse(raw_json)
        is_valid, error_info = validate_tanka_mora(data)

        if is_valid
          return [
            data["ku1"]["text"],
            data["ku2"]["text"],
            data["ku3"]["text"],
            data["ku4"]["text"],
            data["ku5"]["text"]
          ].join(" ")
        else
          feedback = error_info
        end
      rescue JSON::ParserError
        feedback = "JSON形式が崩れていました。指示通りのJSONフォーマットのみを出力してください。"
      end
    end

    "エラー吐き 詠めぬ短歌の 虚しさよ 文字超えゆきて 涙こぼれる"
  rescue StandardError => e
    Rails.logger.error("OpenAI API Error: #{e.message}")
    "エラー吐き 詠めぬ短歌の 虚しさよ 接続切れの 深き絶望"
  end
end
