# 📏 短歌の「読み（ひらがな）」から音数（モーラ数）を数える
# - 拗音・小書きの母音（ゃ ゅ ょ ぁ ぃ ぅ ぇ ぉ ゎ）は前の文字と合わせて1音なので数えない
# - 促音「っ」と長音「ー」は1音として数える
# - カタカナはひらがなに読み替え、それ以外（漢字・英数字・記号・空白）は数えない
module TankaMora
  SMALL_KANA = %w[ゃ ゅ ょ ぁ ぃ ぅ ぇ ぉ ゎ ゕ ゖ].freeze

  module_function

  def count(kana)
    kana.to_s
        .tr("ァ-ヶ", "ぁ-ゖ")
        .gsub(/[^ぁ-ゖー]/, "")
        .chars
        .count { |char| !SMALL_KANA.include?(char) }
  end
end
