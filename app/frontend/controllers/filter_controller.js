import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card", "status", "playlist", "empty"]

  connect() {
    this.apply()
  }

  apply() {
    const status = this.statusTarget.value
    const playlist = this.playlistTarget.value
    let visible = 0

    this.cardTargets.forEach((card) => {
      const match =
        (!status || card.dataset.status === status) &&
        (!playlist || card.dataset.playlistId === playlist)
      card.hidden = !match
      if (match) visible += 1
    })

    this.emptyTarget.hidden = visible > 0
  }
}
