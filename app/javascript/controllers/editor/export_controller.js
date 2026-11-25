import { Controller } from "@hotwired/stimulus"

// Copies the import command to the clipboard and says so on the button for a moment. The label comes from the view.
export default class extends Controller {
  static targets = ["source", "button"]
  static values = { copiedLabel: String, resetMs: { type: Number, default: 2000 } }

  #timer = null

  disconnect() {
    clearTimeout(this.#timer)
  }

  async copy() {
    await navigator.clipboard.writeText(this.sourceTarget.textContent.trim())
    this.#confirm()
  }

  #confirm() {
    const original = this.buttonTarget.textContent
    this.buttonTarget.textContent = this.copiedLabelValue
    clearTimeout(this.#timer)
    this.#timer = setTimeout(() => { this.buttonTarget.textContent = original }, this.resetMsValue)
  }
}
