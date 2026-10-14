import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "form", "title", "select", "newField", "newName"]

  open(event) {
    const { mediaType, tmdbId, title } = event.currentTarget.dataset

    this.formTarget.action =
      `/catalog/${encodeURIComponent(mediaType)}/${encodeURIComponent(tmdbId)}/playlist`
    this.titleTarget.textContent = title
    this.newNameTarget.value = ""
    this.selectTarget.selectedIndex = 0
    this.toggle()
    this.dialogTarget.showModal()
  }

  toggle() {
    const creating = this.selectTarget.value === "new"
    this.newFieldTarget.hidden = !creating
    this.newNameTarget.disabled = !creating
    if (creating) this.newNameTarget.focus()
  }

  close() {
    this.dialogTarget.close()
  }

  closeOnBackdrop(event) {
    if (event.target === this.dialogTarget) this.close()
  }
}
