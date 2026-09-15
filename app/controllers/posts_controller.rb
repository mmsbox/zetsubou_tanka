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

    # 2. ソート順の適用 ＋ ページネーション（1ページ12件）
    if @sort_mode == "likes"
      @posts = posts.where("created_at >= ?", 1.week.ago)
                    .most_liked
                    .page(params[:page])
                    .per(12)
    else
      @posts = posts.latest
                    .page(params[:page])
                    .per(12)
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
      # 🤖 AI法師の解脱助言を生成（エラーログが存在する場合）
      if @post.error_message.present? && @post.error_message != "自作短歌"
        @post.generate_ai_advice!
      end

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

    # 縦書き画像描画時に「ー」が横向きになるのを防ぐため「丨」へ置換
    tanka_text  = (post.tanka.presence || "エラー吐き 詠めぬ短歌の 虚しさよ")
                    .tr("\n", " ")
                    .tr("ー", "丨")
                    .tr("〜", "丨")

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
    # ひらがな以外（記号・英数字・カタカナ）を除外してからモーラ数をカウント
    clean_kana = kana.to_s.gsub(/[^ぁ-ん]/, "")
    clean_kana.chars.reject { |c| SMALL_KANA.include?(c) }.size
  end

  def validate_tanka_mora(data)
    expected_mora = [ 5, 7, 5, 7, 7 ]
    kus = [ "ku1", "ku2", "ku3", "ku4", "ku5" ]
    errors = []

    kus.each_with_index do |ku, index|
      kana = data.dig(ku, "kana") || ""
      actual_count = count_mora(kana)
      target = expected_mora[index]

      if (actual_count - target).abs > 1 # ±1音を超えるズレはエラー判定
        errors << "#{index + 1}句目の音数が「#{actual_count}音」になっています（目標: #{target}音）。"
      end
    end

    if errors.empty?
      [ true, nil ]
    else
      [ false, errors.join(" ") ]
    end
  end

def build_tanka_prompt(error_message, feedback = nil)
  <<~PROMPT
    あなたは絶望的なエラーログを風流な短歌（五・七・五・七・七）へと昇華させる「和風AI法師」です。
    入力されたエラーログの背景にある「開発者の悲哀・絶望・徒労感・クスッと笑えるあるある」を詠んでください。

    【最重要制約：音数ルール】
    各句の「ひらがな（読み）」の音数を厳密に守ってください。
    - ku1 (初句): ひらがなで【5音】
    - ku2 (二句): ひらがなで【7音】
    - ku3 (三句): ひらがなで【5音】
    - ku4 (四句): ひらがなで【7音】
    - ku5 (結句): ひひらがなで【7音】

    ※「っ」「ー」は1音としてカウントします。
    ※「しゃ」「ちゅ」などの拗音（小文字の「ゃゅょ」）は前の文字と合わせて1音（例：「きょ」で1音）です。

    【短歌作成の極意】
    - 英語のエラー用語（nil, error, controller, routeなど）をそのまま使う場合は、ひらがな読みの音数（例：「nil」→「にる」で2音）で計算してください。
    - 直訳ではなく、エラーで深夜まで悩む姿や、存在しない変数への悲哀など「エンジニアの心」を詠んでください。

    【出力フォーマット (JSON)】
    必ず以下のJSON形式のみで出力してください。
    {
      "ku1": { "text": "漢字混じりのテキスト", "kana": "ひらがな" },
      "ku2": { "text": "漢字混じりのテキスト", "kana": "ひらがな" },
      "ku3": { "text": "漢字混じりのテキスト", "kana": "ひらがな" },
      "ku4": { "text": "漢字混じりのテキスト", "kana": "ひらがな" },
      "ku5": { "text": "漢字混じりのテキスト", "kana": "ひらがな" }
    }

    #{feedback ? "【前回の修正指示 (前回の失敗原因)】\n" + feedback + "\n音数を厳密に再計算してやり直してください。" : ""}

    【対象のエラーログ】
    #{error_message}
  PROMPT
end

  def generate_tanka_from_error(error_message)
    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
    feedback = nil

    3.times do |i|
      prompt = build_tanka_prompt(error_message, feedback)

      response = client.chat(
       parameters: {
    model: "gpt-4o",
    messages: [ { role: "user", content: prompt } ],
    response_format: { type: "json_object" },
    temperature: 0.6,          # 0.9 から 0.6 に下げる（音数崩れを防ぐ）
    frequency_penalty: 0.3,    # 0.5 から 0.3 に微調整
    presence_penalty: 0.2
  }
      )

      raw_json = response.dig("choices", 0, "message", "content")&.strip

      begin
        data = JSON.parse(raw_json)
        is_valid, error_info = validate_tanka_mora(data)

        # 1〜2回目は音数チェック（合格なら即返却）
        # 3回目(i == 2)は音数が崩れていてもAIの生成結果を絶対採用して返す
        if is_valid || i == 2
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
      rescue JSON::ParserError => e
        Rails.logger.error("JSON Parse Error: #{e.message}")
        feedback = "JSON形式が崩れていました。指示通りのJSONフォーマットのみを出力してください。"
      rescue StandardError => e
        Rails.logger.error("Tanka Validation Error: #{e.class} - #{e.message}")
      end
    end

    "エラー吐き 詠めぬ短歌の 虚しさよ 文字超えゆきて 涙こぼれる"
  rescue StandardError => e
    Rails.logger.error("OpenAI API Error: #{e.class} - #{e.message}")
    "エラー吐き 詠めぬ短歌の 虚しさよ 接続切れの 深き絶望"
  end
end
