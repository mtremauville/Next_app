import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { delay: { type: Number, default: 4000 } }

  connect() {
    this.remaining = this.delayValue
    this.start()
  }

  disconnect() {
    clearTimeout(this.timer)
  }

  start() {
    this.startedAt = Date.now()
    this.timer = setTimeout(() => this.dismiss(), this.remaining)
  }

  pause() {
    clearTimeout(this.timer)
    this.remaining -= Date.now() - this.startedAt
  }

  resume() {
    this.start()
  }

  dismiss() {
    clearTimeout(this.timer)
    this.element.classList.add("is-leaving")
    setTimeout(() => this.element.remove(), 250)
  }
}
