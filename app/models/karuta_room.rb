# 🎴 合言葉の部屋（2人対戦かるた）
# 対局の状態はすべてこのレコードが持ち、サーバーが審判を務める。
# 同時に札を取られても先着1名だけが有効になるよう、状態を変える操作は with_lock（行ロック）の中で行う。
class KarutaRoom < ApplicationRecord
  class NotEnoughCards < StandardError; end

  belongs_to :host, class_name: "User"
  belongs_to :guest, class_name: "User", optional: true

  CODE_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789".chars.freeze # 見間違えやすい 0/O・1/I は除外
  CODE_LENGTH = 6
  EXPIRES_IN = 1.day
  STATUSES = %w[waiting playing finished].freeze
  # 部屋名は「エラーのタグ ＋ 和風の部屋」で自動命名する（例：無限ループの間）
  ROOM_SUFFIXES = %w[の間 の座敷 の茶室 の離れ の庵 の書院 の広間].freeze

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :active, -> { where(created_at: EXPIRES_IN.ago..) }

  # 部屋を作り、場に並べる札と読む順番を決める
  def self.open!(host)
    cards = Post.karuta_deck.sample(Post::KARUTA_ROUND_SIZE)
    raise NotEnoughCards if cards.size < Post::KARUTA_MIN_CARDS

    create!(
      host: host,
      code: generate_code,
      name: generate_name,
      cards: cards.map(&:deep_stringify_keys),
      reading_order: cards.map { |card| card[:id] }.shuffle
    )
  end

  def self.generate_code
    loop do
      code = Array.new(CODE_LENGTH) { CODE_CHARS.sample }.join
      return code unless exists?(code: code)
    end
  end

  def self.generate_name
    "#{Post::ALL_CATEGORIES.sample}#{ROOM_SUFFIXES.sample}"
  end

  def self.normalize_code(code)
    code.to_s.upcase.gsub(/[^A-Z0-9]/, "")
  end

  def role_of(user)
    return nil unless user
    return "host" if host_id == user.id
    return "guest" if guest_id == user.id
    nil
  end

  # 入室。主か客ならその役割を、満席なら nil を返す。2つ目の戻り値は「今回初めて客として入ったか」
  def join!(user)
    with_lock do
      role = role_of(user)
      return [ role, false ] if role
      return [ nil, false ] unless status == "waiting" && guest_id.nil?

      update!(guest: user)
      [ "guest", true ]
    end
  end

  # 主が対局を始める。始められない状況なら nil
  def start!(user)
    with_lock do
      return nil unless role_of(user) == "host" && status == "waiting" && guest_id.present?

      self.status = "playing"
      begin_next_turn
    end
  end

  # 札を取る。返り値はブロードキャストするイベントの配列（無効な操作なら空）
  def take!(user, card_id, turn_number)
    with_lock do
      role = role_of(user)
      return [] unless role && status == "playing" && turn_open && turn == turn_number
      return [] if missed.include?(role) || taken.key?(card_id.to_s)
      return [] unless card_ids.include?(card_id)

      if card_id == current_card_id
        taken[card_id.to_s] = role
        increment_score(role)
        self.turn_open = false
        save!
        [ event("taken", card_id: card_id, by: role, card: current_card) ]
      else
        take_wrong_card(role)
      end
    end
  end

  # 札が取られた（または流れた）後、次の首へ進める。両者から届いても進むのは1回だけ
  def advance!(turn_number)
    with_lock do
      return nil unless status == "playing" && !turn_open && turn == turn_number

      begin_next_turn
    end
  end

  def public_state
    {
      status: status,
      turn: turn,
      turn_open: turn_open,
      total: reading_order.size,
      taken: taken,
      missed: missed,
      scores: { host: host_score, guest: guest_score },
      otetsuki: { host: host_otetsuki, guest: guest_otetsuki },
      names: { host: display_name(host), guest: guest && display_name(guest) },
      kami: turn_open ? current_card&.dig("kami") : nil
    }
  end

  # ブラウザに渡す札（どの上の句と対応するかは、取られるまで伏せる）
  def field_cards
    cards.map { |card| card.slice("id", "shimo") }
  end

  def current_card
    cards.find { |card| card["id"] == current_card_id }
  end

  private

  def card_ids
    cards.map { |card| card["id"] }
  end

  def current_card_id
    turn.positive? ? reading_order[turn - 1] : nil
  end

  def opponent(role)
    role == "host" ? "guest" : "host"
  end

  def increment_score(role)
    self["#{role}_score"] += 1
  end

  # お手つき：相手に1点。両者お手つきならその札は流れる
  def take_wrong_card(role)
    missed << role
    self["#{role}_otetsuki"] += 1
    increment_score(opponent(role))

    nagare = missed.uniq.size == 2
    if nagare
      taken[current_card_id.to_s] = "none"
      self.turn_open = false
    end
    save!

    [ event("otetsuki", by: role, nagare: nagare, card_id: (current_card_id if nagare), card: (current_card if nagare)) ]
  end

  def begin_next_turn
    self.turn += 1
    self.missed = []

    if turn > reading_order.size
      self.status = "finished"
      self.turn_open = false
      save!
      return event("finished")
    end

    self.turn_open = true
    save!
    event("turn")
  end

  def event(type, **payload)
    { event: type, turn: turn, state: public_state }.merge(payload.compact)
  end

  def display_name(user)
    user.name.presence || "名無し法師"
  end
end
