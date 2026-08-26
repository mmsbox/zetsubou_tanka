class OmikujisController < ApplicationController
  RESULTS = [
    { id: 0, result: "大吉", color: "#d93838", weight: 10, bg_style: "url('/images/omikuji/daikichi.png') center/cover no-repeat" },
    { id: 1, result: "中吉", color: "#e67e22", weight: 15, bg_style: "url('/images/omikuji/chukichi.png') center/cover no-repeat" },
    { id: 2, result: "吉",   color: "#27ae60", weight: 20, bg_style: "url('/images/omikuji/kichi.png') center/cover no-repeat" },
    { id: 3, result: "小吉", color: "#2980b9", weight: 20, bg_style: "url('/images/omikuji/shokichi.png') center/cover no-repeat" },
    { id: 4, result: "大凶", color: "#8c1d1d", weight: 15, bg_style: "url('/images/omikuji/daikyou.png') center/cover no-repeat" },
    { id: 5, result: "極凶", color: "#5b1d8c", weight: 10, bg_style: "url('/images/omikuji/gokukyou.png') center/cover no-repeat" },
    { id: 6, result: "崩壊", color: "#8c531d", weight: 5,  bg_style: "url('/images/omikuji/houkai.png') center/cover no-repeat" },
    { id: 7, result: "終焉", color: "#1d6f8c", weight: 3,  bg_style: "url('/images/omikuji/syuuen.png') center/cover no-repeat" },
    { id: 8, result: "無",   color: "#ffffff", weight: 2,  bg_style: "url('/images/omikuji/mu.png') center/cover no-repeat" }
  ].freeze

  THEMES = [
    { id: 0, theme: "git push -f を誤って叩いてリポが吹き飛んだ絶望", advice: "本日は丁寧なコミットとバックアップを心がけましょう。" },
    { id: 1, theme: "ローカルでは動いたのに本番で500エラーが出る絶望", advice: "環境変数とDockerコンテナの再起動を確認するべし。" },
    { id: 2, theme: "依存ライブラリのバージョン競合でビルドが通らない絶望", advice: "安易な bundle update は控え、ロックファイルを慈しみましょう。" },
    { id: 3, theme: "タイポ一つを探すためだけに3時間が消えた虚しさ", advice: "目を休め、エラーログをAIにそのまま投げるのが吉。" },
    { id: 4, theme: "ログに何も出ず原因不明のまま静まり返る夜の絶望", advice: "サーバーが起動しているか、ポート番号を今一度見直すべし。" }
  ].freeze

  SMALL_KANA = %w[ぁ ぃ ぅ ぇ ぉ ゃ ゅ ょ ァ ィ ゥ ェ ォ ャ ュ ョ].freeze

  def show
    today_key = "omikuji_#{Date.today}"
    cached_session = session[today_key]

    if cached_session.is_a?(Hash) && cached_session["result_id"].present?
      # 既に引いている場合は保存されたIDから再構築（セッションサイズを軽量化）
      result_id = cached_session["result_id"].to_i
      selected_result = RESULTS.find { |r| r[:id] == result_id } || RESULTS.first

      @fortune = {
        result: selected_result[:result],
        color: selected_result[:color],
        bg_style: selected_result[:bg_style],
        tanka: cached_session["tanka"] || "消えたコード 二度と戻らぬ 黄昏に 静かに閉じる エディタの画面",
        advice: cached_session["advice"] || "本日は丁寧なコミットを心がけましょう。"
      }
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

      # 💡 セッション容量オーバー防止：必要最小限のデータのみ保存
      session[today_key] = {
        "result_id" => selected_result[:id],
        "tanka" => tanka,
        "advice" => selected_theme[:advice]
      }
      @already_drawn = false
    end
  rescue StandardError => e
    Rails.logger.error("Omikuji Show Exception: #{e.class} - #{e.message}\n#{e.backtrace&.first(3)&.join("\n")}")

    @fortune = {
      result: "大吉",
      color: "#d93838",
      bg_style: "background: #1a1512;",
      tanka: "バグ消えて 笑顔あふれる 開発の 夢を見し間に 朝が訪れる",
      advice: "焦らずログを見直せば、自ずと道は開かれます。"
    }
    @already_drawn = false
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

  def validate_tanka_mora(data)
    return [ false, "データが存在しません" ] unless data.is_a?(Hash)

    expected = [ 5, 7, 5, 7, 7 ]
    keys = [ "ku1", "ku2", "ku3", "ku4", "ku5" ]
    errors = []

    keys.each_with_index do |key, idx|
      phrase_data = data[key]
      return [ false, "#{key} のデータが存在しません。" ] unless phrase_data && phrase_data["kana"]

      kana = phrase_data["kana"].to_s.gsub(/[[:space:]]/, "")
      actual_count = count_mora(kana)
      target_count = expected[idx]

      if (actual_count - target_count).abs > 1
        errors << "#{key}の読み「#{kana}」は#{actual_count}音です（目標: #{target_count}音）。"
      end
    end

    [ errors.empty?, errors.join("\n") ]
  rescue StandardError => e
    [ false, "モーラ数検証中の例外: #{e.message}" ]
  end

  def generate_ai_tanka(theme)
    if ENV["OPENAI_API_KEY"].blank?
      return "消えたコード 二度と戻らぬ 黄昏に 静かに閉じる エディタの画面"
    end

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
      rescue StandardError => e
        feedback = "JSON解析エラー: #{e.message}"
      end
    end

    "消えたコード 二度と戻らぬ 黄昏に 静かに閉じる エディタの画面"
  rescue StandardError => e
    Rails.logger.error("Omikuji OpenAI Error: #{e.message}")
    "エラー吐き 詠めぬおみくじ 虚しさよ 神の気まぐれ 回線切れぬ"
  end
end
