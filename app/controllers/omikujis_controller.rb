class OmikujisController < ApplicationController
  # 運勢・カラー・確率(weight)・背景スタイルの定義
  # ※ 画像（PNG / WEBP / JPG）が用意できたものから url('/images/omikuji/filename.png') に差し替え可能です！
  RESULTS = [
    { result: "大吉", color: "#d93838", weight: 10, bg_style: "url('/images/omikuji/daikichi.png') center/cover, linear-gradient(135deg, #fff5f5 0%, #ffe3e3 100%)" },
    { result: "中吉", color: "#e67e22", weight: 15, bg_style: "url('/images/omikuji/chukichi.png') center/cover, linear-gradient(135deg, #fff9f2 0%, #ffe8d1 100%)" },
    { result: "吉",   color: "#27ae60", weight: 20, bg_style: "url('/images/omikuji/kichi.png') center/cover, linear-gradient(135deg, #f2faf5 0%, #d1f2dd 100%)" },
    { result: "小吉", color: "#2980b9", weight: 20, bg_style: "url('/images/omikuji/shokichi.png') center/cover, linear-gradient(135deg, #f2f8fa 0%, #d1e8f2 100%)" },
    { result: "大凶", color: "#8c1d1d", weight: 15, bg_style: "linear-gradient(135deg, #2b1111 0%, #1a0a0a 100%)" },
    { result: "極凶", color: "#5b1d8c", weight: 10, bg_style: "linear-gradient(135deg, #1f112b 0%, #0d0614 100%)" },
    { result: "崩壊", color: "#8c531d", weight: 5,  bg_style: "linear-gradient(135deg, #2b1f11 0%, #171008 100%)" },
    { result: "終焉", color: "#1d6f8c", weight: 3,  bg_style: "linear-gradient(135deg, #11252b 0%, #081217 100%)" },
    { result: "無",   color: "#ffffff", weight: 2,  bg_style: "linear-gradient(135deg, #1a1a1a 0%, #000000 100%)" }
  ].freeze

  THEMES = [
    { theme: "git push -f を誤って叩いてリポが吹き飛んだ絶望", advice: "本日は丁寧なコミットとバックアップを心がけましょう。" },
    { theme: "ローカルでは動いたのに本番で500エラーが出る絶望", advice: "環境変数とDockerコンテナの再起動を確認するべし。" },
    { theme: "依存ライブラリのバージョン競合でビルドが通らない絶望", advice: "安易な bundle update は控え、ロックファイルを慈しみましょう。" },
    { theme: "タイポ一つを探すためだけに3時間が消えた虚しさ", advice: "目を休め、エラーログをAIにそのまま投げるのが吉。" },
    { theme: "ログに何も出ず原因不明のまま静まり返る夜の絶望", advice: "サーバーが起動しているか、ポート番号を今一度見直すべし。" }
  ].freeze

  SMALL_KANA = %w[ぁ ぃ ぅ ぇ ぉ ゃ ゅ ょ ァ ィ ゥ ェ ォ ャ ュ ョ].freeze

  def show
    today_key = "omikuji_#{Date.today}"
    cached_data = session[today_key]

    if cached_data.is_a?(Hash)
      @fortune = cached_data.deep_symbolize_keys
      @already_drawn = true
    else
      selected_result = draw_weighted_result(RESULTS)
      selected_theme  = THEMES.sample

      tanka = generate_ai_tanka(selected_theme[:theme])

      @fortune = {
        result: selected_result[:result],
        color: selected_result[:color],
        bg_style: selected_result[:bg_style],
        tanka: tanka,
        advice: selected_theme[:advice]
      }

      session[today_key] = @fortune
      @already_drawn = false
    end
  end

  private

  def draw_weighted_result(results)
    total_weight = results.sum { |r| r[:weight] }
    random_num = rand(total_weight)

    results.each do |r|
      return r if random_num < r[:weight]
      random_num -= r[:weight]
    end

    results.first
  end

  def count_mora(kana)
    kana.to_s.chars.reject { |c| SMALL_KANA.include?(c) }.size
  end

  def generate_ai_tanka(theme)
    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
    feedback = nil

    3.times do
      prompt = <<~PROMPT
        あなたはエンジニアの絶望を詠む「短歌名人」です。
        テーマ「#{theme}」をもとに、共感と絶望感が漂う短歌（5・7・5・7・7）を1首生成してください。

        #{feedback ? "【前回の音数ミスの修正指示】\n#{feedback}\nこれを踏まえて必ず正しい音数で作り直してください。\n" : ""}
        【最重要ルール：音数（モーラ数）】
        各句の「kana」（全ひらがな）の音数を厳格に守ってください。
        - ku1: 5音, ku2: 7音, ku3: 5音, ku4: 7音, ku5: 7音

        【表現のルール】
        - 毎回異なる切り口や表現で詠んでください。

        【出力フォーマット】
        以下のJSON形式のみを出力してください。
        {
          "ku1": {"text": "...", "kana": "..."},
          "ku2": {"text": "...", "kana": "..."},
          "ku3": {"text": "...", "kana": "..."},
          "ku4": {"text": "...", "kana": "..."},
          "ku5": {"text": "...", "kana": "..."}
        }
      PROMPT

      response = client.chat(
        parameters: {
          model: "gpt-4o-mini",
          messages: [{ role: "user", content: prompt }],
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

    "消えたコード 二度と戻らぬ 黄昏に 静かに閉じる エディタの画面"
  rescue StandardError => e
    Rails.logger.error("Omikuji OpenAI Error: #{e.message}")
    "エラー吐き 詠めぬおみくじ 虚しさよ 神の気まぐれ 回線切れぬ"
  end

  def validate_tanka_mora(data)
    expected = [5, 7, 5, 7, 7]
    keys = ["ku1", "ku2", "ku3", "ku4", "ku5"]
    errors = []

    keys.each_with_index do |key, idx|
      phrase_data = data[key]
      return [false, "#{key} のデータが存在しません。"] unless phrase_data && phrase_data["kana"]

      kana = phrase_data["kana"].to_s.gsub(/[[:space:]]/, "")
      actual_count = count_mora(kana)
      target_count = expected[idx]

      if (actual_count - target_count).abs > 1
        errors << "#{key}の読み「#{kana}」は#{actual_count}音です（目標: #{target_count}音）。"
      end
    end

    [errors.empty?, errors.join("\n")]
  end
end
