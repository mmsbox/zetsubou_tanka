import { Controller } from "@hotwired/stimulus"

// 🎴 絶望百人一首：CPU法師との一人用かるた
// 上の句（5・7・5）が一文字ずつ読まれ、場に並んだ下の句（7・7）の札を法師より先に取る

// 難易度ごとに、法師が札を取るまでの時間（読み始めからのミリ秒）
const LEVELS = {
  minarai: { name: "見習い法師", min: 5500, max: 8500 },
  kasei: { name: "歌聖法師", min: 3500, max: 5500 },
  kami: { name: "絶望の神", min: 1800, max: 3200 }
}
const CHAR_INTERVAL = 170 // 上の句を一文字表示する間隔
const NEXT_TURN_DELAY = 2800 // 札が取られてから次の首を読むまで
const MISS_FLASH = 600 // お手つきの札が赤く光る時間

function shuffle(array) {
  const a = [ ...array ]
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [ a[i], a[j] ] = [ a[j], a[i] ]
  }
  return a
}

function randomBetween(min, max) {
  return min + Math.random() * (max - min)
}

export default class extends Controller {
  static targets = [
    "start", "board", "field", "reading", "status",
    "playerScore", "cpuScore", "levelName", "lastCard",
    "result", "resultTitle", "resultDetail", "shareLink", "speechToggle", "saveStatus", "roomPanel"
  ]
  static values = { cards: Array, shareUrl: String, postsPath: String, saveUrl: String }

  connect() {
    this.timers = []
    this.speechOn = false
  }

  disconnect() {
    this.clearTimers()
    this.cancelSpeech()
  }

  // 🔊 上の句の音声読み上げ（ブラウザの音声合成）の切り替え
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

  start(event) {
    this.levelKey = event.params.level in LEVELS ? event.params.level : "kasei"
    this.level = LEVELS[this.levelKey]
    this.playerScore = 0
    this.cpuScore = 0
    this.otetsuki = 0
    this.turn = 0
    this.queue = shuffle(this.cardsValue)

    this.levelNameTarget.textContent = this.level.name
    this.updateScore()
    this.renderField()
    this.lastCardTarget.hidden = true
    this.startTarget.hidden = true
    if (this.hasRoomPanelTarget) this.roomPanelTarget.hidden = true
    this.resultTarget.hidden = true
    this.boardTarget.hidden = false

    this.readingTarget.textContent = ""
    this.statusTarget.textContent = "札を並べ申した。まもなく読み始めます…"
    this.later(() => this.nextTurn(), 1800)
  }

  renderField() {
    this.fieldTarget.replaceChildren()
    shuffle(this.cardsValue).forEach((card) => {
      const fuda = document.createElement("button")
      fuda.type = "button"
      fuda.className = "karuta-fuda"
      fuda.dataset.cardId = card.id
      fuda.dataset.action = "karuta#take"
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
  }

  nextTurn() {
    this.current = this.queue.shift()
    if (!this.current) {
      this.finish()
      return
    }

    this.turn += 1
    this.turnOpen = true
    this.missed = false
    this.readingTarget.textContent = ""
    this.statusTarget.textContent = `第${this.turn}首 ― 読み上げ中…`

    this.readKami(this.current.kami.join("　"))
    this.later(() => this.cpuTake(), randomBetween(this.level.min, this.level.max))
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

  take(event) {
    const fuda = event.currentTarget
    if (!this.turnOpen || fuda.disabled) return

    if (this.missed) {
      this.statusTarget.textContent = "お手つきの後は、この首には手を出せませぬ…"
      return
    }

    if (Number(fuda.dataset.cardId) === this.current.id) {
      this.resolveTurn("player", fuda)
    } else {
      // お手つき：この首は取れなくなり、法師に1点献上
      this.missed = true
      this.otetsuki += 1
      this.cpuScore += 1
      this.updateScore()
      this.statusTarget.textContent = "お手つき！ 法師に一点献上…"
      fuda.classList.add("is-miss")
      setTimeout(() => fuda.classList.remove("is-miss"), MISS_FLASH)
    }
  }

  cpuTake() {
    if (!this.turnOpen) return
    this.resolveTurn("cpu", this.findFuda(this.current.id))
  }

  resolveTurn(winner, fuda) {
    this.turnOpen = false
    this.clearTimers()
    this.cancelSpeech()
    this.readingTarget.textContent = this.current.kami.join("　")

    if (fuda) {
      fuda.disabled = true
      fuda.classList.add(winner === "player" ? "is-taken-player" : "is-taken-cpu")
    }

    if (winner === "player") {
      this.playerScore += 1
      this.statusTarget.textContent = "見事！ 札を取り申した。"
    } else {
      this.cpuScore += 1
      this.statusTarget.textContent = `${this.level.name}に取られた…`
    }
    this.updateScore()
    this.showLastCard(this.current)

    this.later(() => this.nextTurn(), NEXT_TURN_DELAY)
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

  finish() {
    this.readingTarget.textContent = ""
    this.statusTarget.textContent = "全ての札が取られ申した。"

    let title
    if (this.playerScore > this.cpuScore) title = "🏆 勝利"
    else if (this.playerScore < this.cpuScore) title = "💀 敗北"
    else title = "🤝 引き分け"

    const detail = `${this.level.name}との勝負：${this.playerScore} 対 ${this.cpuScore}（お手つき ${this.otetsuki} 回）`
    this.resultTitleTarget.textContent = title
    this.resultDetailTarget.textContent = detail

    const shareText = `【絶望百人一首】${title.replace(/^\S+\s/, "")}\n${detail}\n\n`
    const params = new URLSearchParams({
      text: shareText,
      url: this.shareUrlValue,
      hashtags: "絶望百人一首,絶望えらぁ短歌"
    })
    this.shareLinkTarget.href = `https://twitter.com/intent/tweet?${params.toString()}`

    this.resultTarget.hidden = false
    this.resultTarget.scrollIntoView({ behavior: "smooth", block: "center" })
    this.saveResult()
  }

  // 📜 ログイン中なら戦績をサーバーに記録（未ログイン時は saveUrl が空で、ログイン案内がビューに出ている）
  async saveResult() {
    if (!this.saveUrlValue) return

    this.saveStatusTarget.textContent = "戦績を記録しております…"
    try {
      const response = await fetch(this.saveUrlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content || ""
        },
        body: JSON.stringify({
          karuta_result: {
            level: this.levelKey,
            player_score: this.playerScore,
            cpu_score: this.cpuScore,
            otetsuki: this.otetsuki,
            card_count: this.cardsValue.length
          }
        })
      })
      if (!response.ok) throw new Error(`status ${response.status}`)

      const data = await response.json()
      const rank = data.rank ? `（現在の称号：${data.rank.icon} ${data.rank.title}）` : ""
      this.saveStatusTarget.textContent = `📜 戦績をマイページに記録し申した${rank}`
    } catch (error) {
      console.error("Karuta result save failed:", error)
      this.saveStatusTarget.textContent = "戦績の記録に失敗し申した…"
    }
  }

  findFuda(id) {
    return this.fieldTarget.querySelector(`[data-card-id="${id}"]`)
  }

  updateScore() {
    this.playerScoreTarget.textContent = this.playerScore
    this.cpuScoreTarget.textContent = this.cpuScore
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
