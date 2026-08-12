class OmikujisController < ApplicationController
  THEMES = [
    { result: "大凶", color: "#8c1d1d", theme: "git push -f を誤って叩いてリポが吹き飛んだ絶望", advice: "本日は丁寧なコミットとバックアップを心がけましょう。" },
    { result: "極凶", color: "#5b1d8c", theme: "ローカルでは動いたのに本番で500エラーが出る絶望", advice: "環境変数とDockerコンテナの再起動を確認するべし。" },
    { result: "崩壊", color: "#8c531d", theme: "依存ライブラリのバージョン競合でビルドが通らない絶望", advice: "安易な bundle update は控え、ロックファイルを慈しみましょう。" },
    { result: "終焉", color: "#1d6f8c", theme: "タイポ一つを探すためだけに3時間が消えた虚しさ", advice: "目を休め、エラーログをChatGPTにそのまま投げるのが吉。" },
    { result: "無",   color: "#333333", theme: "ログに何も出ず原因不明のまま静まり返る夜の絶望", advice: "サーバーが起動しているか、ポート番号を今一度見直すべし。" }
  ].freeze

  SMALL_KANA = %w[ぁ ぃ ぅ ぇ ぉ ゃ ゅ ょ ァ ィ ゥ ェ ォ ャ ュ ョ].freeze

  def show
    today_key = "omikuji_#{Date.today}"
    cached_data = session[today_key]

    # すでにハッシュデータとして保存されている場合
    if cached_data.is_a?(Hash)
      @fortune = cached_data.deep_symbolize_keys
      @already_drawn = true
    else
      # 新しくAIおみくじを生成
      selected = THEMES.sample
      tanka = generate_ai_tanka(selected[:theme])

      @fortune = {
        result: selected[:result],
        color: selected[:color],
        tanka: tanka,
        advice: selected[:advice]
      }

      session[today_key] = @fortune
      @already_drawn = false
    end
  end

  private

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
          temperature: 0.7
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

      if actual_count != target_count
        errors << "#{key}の読み「#{kana}」は#{actual_count}音です（目標: #{target_count}音）。"
      end
    end

    [errors.empty?, errors.join("\n")]
  end
end
