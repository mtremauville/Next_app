import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "button"]

  connect() {
    this.outside = (event) => {
      if (!this.element.contains(event.target)) this.close()
    }
    this.escape = (event) => {
      if (event.key === "Escape") this.close()
    }
    document.addEventListener("click", this.outside)
    document.addEventListener("keydown", this.escape)
  }

  disconnect() {
    document.removeEventListener("click", this.outside)
    document.removeEventListener("keydown", this.escape)
  }

  toggle() {
    const open = this.menuTarget.classList.toggle("is-open")
    this.buttonTarget.setAttribute("aria-expanded", open)
  }

  close() {
    this.menuTarget.classList.remove("is-open")
    this.buttonTarget.setAttribute("aria-expanded", "false")
  }
}
