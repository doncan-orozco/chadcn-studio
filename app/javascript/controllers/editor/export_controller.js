import { Controller } from "@hotwired/stimulus"

// The export dialog's feedback: copies the import command and says so on the button for a moment, and notes that a
// download was started (the browser gives no finish event for one). The labels come from the view.
export default class extends Controller {
  static targets = ["source", "button", "status", "downloadStatus"]
  static values = { copiedLabel: String, downloadedLabel: String, resetMs: { type: Number, default: 2000 } }

  #timer = null
  #downloadTimer = null
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

    clearTimeout(this.#downloadTimer)
    this.downloadStatusTarget.textContent = "" // Cleared first so a repeat download is announced again.
    requestAnimationFrame(() => {
      if (this.hasDownloadStatusTarget) this.downloadStatusTarget.textContent = this.downloadedLabelValue
    })
    this.#downloadTimer = setTimeout(() => this.#clearDownloadStatus(), this.resetMsValue)
  }

  #confirm() {
    clearTimeout(this.#timer)
    this.buttonTarget.textContent = this.copiedLabelValue
    this.statusTarget.textContent = this.copiedLabelValue
    this.#timer = setTimeout(() => this.#restore(), this.resetMsValue)
  }

  #clearDownloadStatus() {
    clearTimeout(this.#downloadTimer)
    this.#downloadTimer = null
    if (this.hasDownloadStatusTarget) this.downloadStatusTarget.textContent = ""
  }

  #restore() {
    clearTimeout(this.#timer)
    this.#timer = null
    this.#clearDownloadStatus()
    if (this.hasStatusTarget) this.statusTarget.textContent = ""
    if (this.#originalLabel !== null && this.hasButtonTarget) this.buttonTarget.textContent = this.#originalLabel
  }
}
