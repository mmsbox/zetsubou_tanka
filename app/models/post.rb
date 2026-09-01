class Post < ApplicationRecord
  belongs_to :user, optional: true

  # 返歌用の自己参照リレーション
  belongs_to :parent, class_name: "Post", optional: true
  has_many :replies, class_name: "Post", foreign_key: "parent_id", dependent: :destroy

  # 必達チェック：短歌本文かエラーメッセージのどちらかが存在すること
  validates :tanka, presence: true, if: -> { error_message.blank? }
  validates :error_message, presence: true, if: -> { tanka.blank? }

  # 🏷️ グループ別エラー・タグ定義
  CATEGORY_GROUPS = {
    "🏫 RUNTEQ生活" => %w[カリキュラム詰まり 学習記録 入学直後 卒業制作 転職活動 仲間募集],
    "💻 エラー種別" => %w[SyntaxError NullPointer NoMethodError UndefinedVariable 型エラー API連携バグ],
    "⚙️ 環境・DB" => %w[環境構築 Docker事故 本番DB事故 マイグレーション Gem依存関係],
    "🔥 人為的ミス" => %w[タイポ 無限ループ Git事故 誤コミット 仕様見落とし]
  }.freeze

  # 全タグの一覧リスト
  ALL_CATEGORIES = CATEGORY_GROUPS.values.flatten.freeze

  # 🏷️ 絞り込み用スコープ
  scope :by_category, ->(category) { where(error_category: category) if category.present? }

  # ソート用スコープ
  scope :latest, -> { reorder(created_at: :desc) }
  scope :most_liked, -> { reorder(Arel.sql("COALESCE(likes_count, 0) DESC, created_at DESC")) }

  # 🤖 会員投稿時にAIアドバイスを生成する処理
  def generate_ai_advice!
    # 解析対象（エラーメッセージ本文、または短歌本文）
    target_text = error_message.presence || tanka.presence
    return if target_text.blank? || ENV["OPENAI_API_KEY"].blank?

    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

    prompt = <<~PROMPT
      あなたは優しく優秀なシニアエンジニアです。
      ユーザーが投稿した以下のエラー・絶望内容を読み、プログラミング初心者にもわかりやすい技術的な解決のヒントと励ましを150文字程度で作成してください。

      【投稿内容】
      #{target_text}

      【構成】
      ・エラーの主な原因（一言で）
      ・まず確認・試すべきアクション（1〜2点）
      ・温かい励まし
    PROMPT

    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [ { role: "user", content: prompt } ],
        temperature: 0.7,
        max_tokens: 300
      }
    )

    advice = response.dig("choices", 0, "message", "content")&.strip
    update(ai_advice: advice) if advice.present?
  rescue StandardError => e
    Rails.logger.error("AI Advice Generation Error: #{e.message}")
  end
end
