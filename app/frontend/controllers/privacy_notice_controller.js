import { Controller } from "@hotwired/stimulus"

const KEY = "next:privacy-notice-seen"

export default class extends Controller {
  static targets = ["dialog"]

  connect() {
    if (this.seen()) return

    this.timer = setTimeout(() => {
      if (this.hasDialogTarget && !this.dialogTarget.open) this.dialogTarget.showModal()
    }, 400)
  }

  disconnect() {
    clearTimeout(this.timer)
    if (this.hasDialogTarget && this.dialogTarget.open) this.dialogTarget.close()
  }

  close() {
    this.dialogTarget.close()
  }

  remember() {
    try {
      localStorage.setItem(KEY, "1")
    } catch {
      // stockage indisponible : la modale s'affichera à la prochaine visite
    }
  }

  seen() {
    try {
      return localStorage.getItem(KEY) === "1"
    } catch {
      return false
    }
  }
}
