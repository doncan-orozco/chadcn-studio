import { Controller } from "@hotwired/stimulus"

// Narrows the override rows by variable name, and hides a mode's heading when none of its rows match. Rows are hidden, not
// removed, so their fields still post with the form; rows the derivation stream swaps in are filtered on arrival. The
// "nothing found" copy comes from the view.
export default class extends Controller {
  static targets = ["query", "row", "status"]
  static values = { emptyLabel: String }

  connect() {
    this.filter()
  }

  rowTargetConnected() {
    this.filter()
  }

  rowTargetDisconnected() {
    this.#report()
  }

  filter() {
    const query = this.#query()
    this.rowTargets.forEach((row) => { row.hidden = !this.#matches(row, query) })
    this.#sections().forEach((section) => { section.hidden = !section.querySelector("[data-variable]:not([hidden])") })
    this.#report()
  }

  // Enter in the filter must not submit the editor form.
  preventSubmit(event) {
    if (event.isComposing) return
    event.preventDefault()
  }

  #query() {
    if (!this.hasQueryTarget) return ""
    return this.queryTarget.value.trim().toLowerCase().replace(/^-+/, "")
  }

  #matches(row, query) {
    return query === "" || (row.dataset.variable || "").includes(query)
  }

  #sections() {
    return new Set(this.rowTargets.map((row) => row.closest("section")).filter(Boolean))
  }

  #report() {
    if (!this.hasStatusTarget) return
    const anyShown = this.rowTargets.some((row) => !row.hidden)
    this.statusTarget.textContent = anyShown || this.rowTargets.length === 0 ? "" : this.emptyLabelValue
  }
}
