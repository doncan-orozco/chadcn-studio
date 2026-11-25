import { Controller } from "@hotwired/stimulus"

// Opens another group's panel from a link inside this one, by clicking that group's sidebar entry (the gem's dialog handles
// state and aria), then moves focus to the field named by the view: the link's own panel closes at the same time, and focus
// would otherwise fall back to the page. The ids come from the view.
export default class extends Controller {
  static values = { triggerId: String, focusId: String }

  #frame = null

  disconnect() {
    cancelAnimationFrame(this.#frame)
  }

  open() {
    document.getElementById(this.triggerIdValue)?.click()
    this.#frame = requestAnimationFrame(() => document.getElementById(this.focusIdValue)?.focus())
  }
}
