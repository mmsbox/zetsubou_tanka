class PostsController < ApplicationController
def index
    @sort = params[:sort].to_s.strip

    @posts = case @sort
    when "likes"
               Post.most_liked
    else
               Post.latest
    end
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
    @post = Post.new
    if user_signed_in? && current_user.name.present?
      @post.author_name = current_user.name
    end
  end

  def create
    @post = Post.new(post_params)
    @post.user = current_user if user_signed_in?

    if @post.tanka.blank?
      @post.tanka = generate_tanka_from_error(@post.error_message)
    end

    if @post.save
      redirect_to post_path(@post), notice: "短歌が詠まれました！"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def ogp
    @post = Post.find(params[:id])

    tanka_text = @post.tanka.presence || "エラー吐き 詠めぬ短歌の 虚しさよ"
    author_text = "詠み手：#{@post.author_name.presence || '名無し法師'}"

    image = ImageProcessing::MiniMagick
              .source(MiniMagick::Image.create { |f|
                f.write "blank.png"
              }.tap do |img|
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

  # POST /posts/:id/like
  def like
    @post = Post.find(params[:id])
    @post.increment!(:likes_count)
    render json: { likes_count: @post.likes_count }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Post not found" }, status: :not_found
  end

  private

  def post_params
    params.require(:post).permit(:author_name, :error_message, :tanka, :likes_count)
  end

  SMALL_KANA = %w[ぁ ぃ ぅ ぇ ぉ ゃ ゅ ょ ァ ィ ゥ ェ ォ ャ ュ ョ].freeze

  def count_mora(kana)
    kana.to_s.chars.reject { |c| SMALL_KANA.include?(c) }.size
  end

  def build_tanka_prompt(error_message, feedback)
    <<~PROMPT
      あなたはプログラミングのエラーに苦しむエンジニアの悲惨さを詠む「短歌名人」です。
      入力されたエラーログをもとに、共感と絶望感が漂う短歌（5・7・5・7・7）を1首生成してください。

      #{feedback ? "【前回の音数ミスの修正指示】\n#{feedback}\nこれを踏まえて必ず正しい音数で作り直してください。\n" : ""}
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

  def validate_tanka_mora(data)
    expected = [ 5, 7, 5, 7, 7 ]
    keys = [ "ku1", "ku2", "ku3", "ku4", "ku5" ]
    errors = []

    keys.each_with_index do |key, idx|
      phrase_data = data[key]
      return [ false, "#{key} のデータが存在しません。" ] unless phrase_data && phrase_data["kana"]

      kana = phrase_data["kana"].to_s.gsub(/[[:space:]]/, "")
      actual_count = count_mora(kana)
      target_count = expected[idx]

      # ★ 字余り・字足らずを±1音許容してフォールバック落ちを防ぐ
      if (actual_count - target_count).abs > 1
        errors << "#{key}の読み「#{kana}」は#{actual_count}音です（目標: #{target_count}音）。"
      end
    end

    if errors.empty?
      [ true, nil ]
    else
      [ false, errors.join("\n") ]
    end
  end
end
