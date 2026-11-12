import { Controller } from "@hotwired/stimulus"
import { cable } from "@hotwired/turbo-rails"

// ⚔️ 合言葉の部屋：2人対戦かるた
// 審判はサーバー（KarutaRoom）。ここでは操作を送り、届いたイベントに合わせて画面を描くだけ

const CHAR_INTERVAL = 170 // 上の句を一文字表示する間隔
const NEXT_TURN_DELAY = 2800 // 札が取られてから次の首へ進むまで
const MISS_FLASH = 600 // お手つきの札が赤く光る時間

function shuffle(array) {
  const a = [ ...array ]
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [ a[i], a[j] ] = [ a[j], a[i] ]
  }
  return a
}

export default class extends Controller {
  static targets = [
    "connection", "waiting", "waitingStatus", "startButton", "roomUrl", "copyButton", "speechToggle",
    "board", "myScore", "opponentScore", "opponentName", "progress", "reading", "status", "field",
    "lastCard", "result", "resultTitle", "resultDetail", "shareLink"
  ]
  static values = { code: String, roomName: String, role: String, state: Object, cards: Array, postsPath: String, shareUrl: String }

  connect() {
    this.timers = []
    this.speechOn = false
    this.state = this.stateValue
    this.me = this.roleValue
    this.opponent = this.me === "host" ? "guest" : "host"

    this.render()
    this.resume()
    this.subscribe()
  }

  disconnect() {
    this.gone = true
    this.clearTimers()
    this.cancelSpeech()
    this.subscription?.unsubscribe()
  }

  // ---- 通信 -------------------------------------------------------------

  async subscribe() {
    const subscription = await cable.subscribeTo(
      { channel: "KarutaRoomChannel", code: this.codeValue },
      {
        connected: () => this.onConnected(),
        disconnected: () => this.setConnection("⚠️ 接続が切れました。再接続を試みております…", true),
        rejected: () => this.setConnection("⚠️ この部屋に接続できませんでした。", true),
        received: (data) => this.received(data)
      }
    )
    if (this.gone) {
      subscription.unsubscribe()
      return
    }
    this.subscription = subscription
  }

  onConnected() {
    // 切断中に進んだ対局を取りこぼさないよう、再接続時はページを読み直して状態を合わせる
    if (this.wasConnected) {
      window.Turbo ? window.Turbo.visit(window.location.href, { action: "replace" }) : window.location.reload()
      return
    }
    this.wasConnected = true
    this.setConnection("🟢 接続中", false)
  }

  perform(action, data = {}) {
    this.subscription?.perform(action, data)
  }

  received(data) {
    this.state = data.state

    switch (data.event) {
      case "joined":
        this.render()
        break
      case "turn":
        this.onTurn()
        break
      case "taken":
        this.onResolved(data, data.by === this.me ? "見事！ 札を取り申した。" : `${this.opponentName()}に取られた…`)
        break
      case "otetsuki":
        this.onOtetsuki(data)
        break
      case "finished":
        this.clearTimers()
        this.render()
        break
    }
  }

  // ---- 操作 -------------------------------------------------------------

  start() {
    this.startButtonTarget.disabled = true
    this.perform("start")
  }

  take(event) {
    const fuda = event.currentTarget
    if (fuda.disabled || !this.state.turn_open) return

    if (this.state.missed.includes(this.me)) {
      this.statusTarget.textContent = "お手つきの後は、この首には手を出せませぬ…"
      return
    }
    this.lastClicked = fuda
    this.perform("take", { card_id: Number(fuda.dataset.cardId), turn: this.state.turn })
  }

  copy() {
    const url = this.roomUrlTarget.value
    const done = () => { this.copyButtonTarget.textContent = "写し申した" }
    if (navigator.clipboard) {
      navigator.clipboard.writeText(url).then(done).catch(() => this.roomUrlTarget.select())
    } else {
      this.roomUrlTarget.select()
    }
  }

  toggleSpeech() {
    if (!("speechSynthesis" in window)) {
      this.speechToggleTarget.textContent = "🔇 読み上げ非対応"
      this.speechToggleTarget.disabled = true
      return
    }
    this.speechOn = !this.speechOn
    this.speechToggleTarget.textContent = this.speechOn ? "🔊 読み上げ：有" : "🔇 読み上げ：無"
    if (!this.speechOn) this.cancelSpeech()
  }

  // ---- イベント処理 -----------------------------------------------------

  onTurn() {
    this.clearTimers()
    this.cancelSpeech()
    this.render()
    this.lastCardTarget.hidden = true
    this.readingTarget.textContent = ""
    this.statusTarget.textContent = `第${this.state.turn}首 ― 読み上げ中…`
    this.readKami(this.state.kami.join("　"))
  }

  onOtetsuki(data) {
    if (data.nagare) {
      this.onResolved(data, "両者お手つき…この札は流れ申した。")
      return
    }

    this.renderScores()
    if (data.by === this.me) {
      this.statusTarget.textContent = "お手つき！ 相手に一点献上…"
      const fuda = this.lastClicked
      if (fuda) {
        fuda.classList.add("is-miss")
        setTimeout(() => fuda.classList.remove("is-miss"), MISS_FLASH)
      }
    } else {
      this.statusTarget.textContent = `${this.opponentName()}がお手つき！ あなたに一点。`
    }
  }

  // 札が取られた／流れた：上の句を全部見せ、少し待って次の首へ
  onResolved(data, message) {
    this.clearTimers()
    this.cancelSpeech()
    if (data.card) this.readingTarget.textContent = data.card.kami.join("　")
    this.applyTaken()
    this.renderScores()
    this.statusTarget.textContent = message
    if (data.card) this.showLastCard(data.card)
    this.scheduleAdvance()
  }

  scheduleAdvance() {
    const turn = this.state.turn
    this.later(() => this.perform("advance", { turn }), NEXT_TURN_DELAY)
  }

  // ページを開いた（読み直した）時点で対局中なら、続きから再開する
  resume() {
    if (this.state.status !== "playing") return

    if (this.state.turn_open && this.state.kami) {
      this.readingTarget.textContent = this.state.kami.join("　")
      this.statusTarget.textContent = `第${this.state.turn}首 ― 札を取りなされ`
    } else {
      this.statusTarget.textContent = "次の首を待っております…"
      this.scheduleAdvance()
    }
  }

  // ---- 描画 -------------------------------------------------------------

  render() {
    const { status, names } = this.state
    this.opponentNameTarget.textContent = this.opponentName()

    if (status === "waiting") {
      this.waitingTarget.hidden = false
      this.boardTarget.hidden = true
      if (this.me === "host") {
        this.startButtonTarget.disabled = !names.guest
        this.waitingStatusTarget.textContent = names.guest
          ? `${names.guest}が入室しました。いざ、対局を！`
          : "対戦相手の入室を待っております…"
      } else {
        this.waitingStatusTarget.textContent = `「${this.roomNameValue}」に入室しました。${names.host}が対局を始めるのを待っております…`
      }
      return
    }

    this.waitingTarget.hidden = true
    this.boardTarget.hidden = false
    if (!this.fieldRendered) this.renderField()
    this.applyTaken()
    this.renderScores()

    if (status === "finished") this.showResult()
  }

  renderField() {
    this.fieldTarget.replaceChildren()
    shuffle(this.cardsValue).forEach((card) => {
      const fuda = document.createElement("button")
      fuda.type = "button"
      fuda.className = "karuta-fuda"
      fuda.dataset.cardId = card.id
      fuda.dataset.action = "karuta-room#take"
      fuda.setAttribute("aria-label", `下の句 ${card.shimo.join(" ")}`)

      const text = document.createElement("span")
      text.className = "karuta-fuda-text"
      card.shimo.forEach((phrase) => {
        const line = document.createElement("span")
        line.textContent = phrase
        text.appendChild(line)
      })
      fuda.appendChild(text)
      this.fieldTarget.appendChild(fuda)
    })
    this.fieldRendered = true
  }

  applyTaken() {
    const classes = { [this.me]: "is-taken-player", [this.opponent]: "is-taken-cpu", none: "is-nagare" }
    this.fieldTarget.querySelectorAll(".karuta-fuda").forEach((fuda) => {
      const owner = this.state.taken[fuda.dataset.cardId]
      if (!owner) return
      fuda.disabled = true
      fuda.classList.add(classes[owner])
    })
  }

  renderScores() {
    this.myScoreTarget.textContent = this.state.scores[this.me]
    this.opponentScoreTarget.textContent = this.state.scores[this.opponent]
    const turn = Math.min(this.state.turn, this.state.total)
    this.progressTarget.textContent = `第${turn}首 / 全${this.state.total}首`
  }

  showLastCard(card) {
    this.lastCardTarget.replaceChildren()

    const tanka = document.createElement("a")
    tanka.href = `${this.postsPathValue}/${card.id}`
    tanka.className = "karuta-last-tanka"
    tanka.textContent = [ ...card.kami, ...card.shimo ].join("　")

    const author = document.createElement("div")
    author.className = "karuta-last-author"
    author.textContent = `詠み手：${card.author}`

    this.lastCardTarget.append(tanka, author)
    this.lastCardTarget.hidden = false
  }

  showResult() {
    this.readingTarget.textContent = ""
    this.statusTarget.textContent = "全ての札が取られ申した。"

    const mine = this.state.scores[this.me]
    const theirs = this.state.scores[this.opponent]
    let title
    if (mine > theirs) title = "🏆 勝利"
    else if (mine < theirs) title = "💀 敗北"
    else title = "🤝 引き分け"

    const detail = `${this.opponentName()}との勝負：${mine} 対 ${theirs}（お手つき ${this.state.otetsuki[this.me]} 回）`
    this.resultTitleTarget.textContent = title
    this.resultDetailTarget.textContent = detail

    const params = new URLSearchParams({
      text: `【絶望百人一首・${this.roomNameValue}】${title.replace(/^\S+\s/, "")}\n${detail}\n\n`,
      url: this.shareUrlValue,
      hashtags: "絶望百人一首,絶望えらぁ短歌"
    })
    this.shareLinkTarget.href = `https://twitter.com/intent/tweet?${params.toString()}`
    this.resultTarget.hidden = false
  }

  readKami(text) {
    [ ...text ].forEach((char, i) => {
      this.later(() => { this.readingTarget.textContent += char }, i * CHAR_INTERVAL)
    })

    if (this.speechOn && "speechSynthesis" in window) {
      const utterance = new SpeechSynthesisUtterance(text)
      utterance.lang = "ja-JP"
      utterance.rate = 0.85
      window.speechSynthesis.speak(utterance)
    }
  }

  // ---- 補助 -------------------------------------------------------------

  opponentName() {
    return this.state.names[this.opponent] || "対戦相手"
  }

  setConnection(text, offline) {
    this.connectionTarget.textContent = text
    this.connectionTarget.classList.toggle("is-offline", offline)
  }

  later(callback, delay) {
    this.timers.push(setTimeout(callback, delay))
  }

  clearTimers() {
    this.timers.forEach((timer) => clearTimeout(timer))
    this.timers = []
  }

  cancelSpeech() {
    if ("speechSynthesis" in window) window.speechSynthesis.cancel()
  }
}
