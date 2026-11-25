import { Controller } from "@hotwired/stimulus"

// Opens another group's panel from a link inside this one, by clicking that group's sidebar entry (the gem's dialog handles
// the rest: state, focus, aria). The id of the entry comes from the view.
export default class extends Controller {
  static values = { triggerId: String }

  open() {
    document.getElementById(this.triggerIdValue)?.click()
  }
}
