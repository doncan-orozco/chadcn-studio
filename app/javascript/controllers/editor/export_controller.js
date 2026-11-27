import { Controller } from "@hotwired/stimulus"

// The export dialog's feedback: copies the import command and says so on the button for a moment, and notes that a
// download was started (the browser gives no finish event for one) and keeps saying so until the dialog closes or
// another download starts. The labels come from the view.
export default class extends Controller {
  static targets = ["source", "button", "status", "downloadStatus"]
  static values = { copiedLabel: String, downloadedLabel: String, resetMs: { type: Number, default: 2000 } }

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

  downloaded() {
    if (!this.hasDownloadStatusTarget) return

    this.downloadStatusTarget.textContent = "" // Cleared first so a repeat download is announced again.
    requestAnimationFrame(() => {
      if (this.hasDownloadStatusTarget) this.downloadStatusTarget.textContent = this.downloadedLabelValue
    })
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
