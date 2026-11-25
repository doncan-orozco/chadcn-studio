import { Controller } from "@hotwired/stimulus"

// Narrows the override rows by variable name. Rows are hidden, not removed, so their fields still post with the form; rows the
// derivation stream swaps in are filtered on arrival. The "nothing found" copy comes from the view.
export default class extends Controller {
  static targets = ["query", "row", "status"]
  static values = { emptyLabel: String }

  rowTargetConnected(row) {
    row.hidden = !this.#matches(row)
    this.#report()
  }

  filter() {
    this.rowTargets.forEach((row) => { row.hidden = !this.#matches(row) })
    this.#report()
  }

  // Enter in the filter must not submit the editor form.
  ignore(event) {
    event.preventDefault()
  }

  #matches(row) {
    const query = this.queryTarget.value.trim().toLowerCase().replace(/^-+/, "")
    return query === "" || row.dataset.variable.includes(query)
  }

  #report() {
    if (!this.hasStatusTarget) return
    const anyShown = this.rowTargets.some((row) => !row.hidden)
    this.statusTarget.textContent = anyShown ? "" : this.emptyLabelValue
  }
}
