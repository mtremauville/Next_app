import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card", "status", "playlist", "genre", "empty"]

  connect() {
    this.apply()
  }

  apply() {
    const status = this.statusTarget.value
    const playlist = this.playlistTarget.value
    const genre = this.genreTarget.value
    let visible = 0

    this.cardTargets.forEach((card) => {
      const match =
        (!status || card.dataset.status === status) &&
        (!playlist || card.dataset.playlistId === playlist) &&
        (!genre || (card.dataset.genres || "").split("|").includes(genre))
      card.hidden = !match
      if (match) visible += 1
    })

    this.emptyTarget.hidden = visible > 0
  }
}
