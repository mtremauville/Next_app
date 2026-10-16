import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "button", "backdrop", "inert"]

  get isOpen() {
    return this.panelTarget.classList.contains("is-open")
  }

  toggle() {
    this.isOpen ? this.close() : this.open()
  }

  open() {
    this.panelTarget.classList.add("is-open")
    this.backdropTarget.hidden = false
    this.setInert(true)
    this.buttonTarget.setAttribute("aria-expanded", "true")
    this.panelTarget.querySelector("a, button")?.focus()
  }

  close() {
    if (!this.isOpen) return

    this.reset()
    this.buttonTarget.focus()
  }

  reset() {
    this.panelTarget.classList.remove("is-open")
    this.backdropTarget.hidden = true
    this.setInert(false)
    this.buttonTarget.setAttribute("aria-expanded", "false")
  }

  setInert(value) {
    this.inertTargets.forEach((element) => {
      element.inert = value
    })
  }
}
