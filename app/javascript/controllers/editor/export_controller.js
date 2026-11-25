import { Controller } from "@hotwired/stimulus"

// Copies the import command to the clipboard and says so on the button for a moment. The label comes from the view.
export default class extends Controller {
  static targets = ["source", "button", "status"]
  static values = { copiedLabel: String, resetMs: { type: Number, default: 2000 } }

  #timer = null
  #originalLabel = null

  connect() {
    this.#originalLabel = this.buttonTarget.textContent
  }

  disconnect() {
    this.#restore()
  }

  async copy() {
    try {
      await navigator.clipboard.writeText(this.sourceTarget.textContent.trim())
    } catch {
      return // The clipboard is blocked here; the command stays selectable in the block, and no confirmation is claimed.
    }
    this.#confirm()
  }

  #confirm() {
    clearTimeout(this.#timer)
    this.buttonTarget.textContent = this.copiedLabelValue
    this.statusTarget.textContent = this.copiedLabelValue
    this.#timer = setTimeout(() => this.#restore(), this.resetMsValue)
  }

  #restore() {
    clearTimeout(this.#timer)
    this.#timer = null
    if (this.hasStatusTarget) this.statusTarget.textContent = ""
    if (this.#originalLabel !== null && this.hasButtonTarget) this.buttonTarget.textContent = this.#originalLabel
  }
}
