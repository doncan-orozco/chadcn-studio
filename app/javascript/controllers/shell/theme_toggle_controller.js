import { Controller } from "@hotwired/stimulus"

// Mirrors the chosen color scheme (`data-theme` on <html>, set by the gem's chadcn--theme controller) into `aria-pressed`
// on the Light / Dark / System buttons, so the active one is announced and styled as pressed.
export default class extends Controller {
  static targets = ["button"]

  connect() {
    this.sync()
  }

  // Runs after the gem's controller has written `data-theme` (connect order and its `changed` event both precede this call).
  sync() {
    const current = document.documentElement.dataset.theme || "system"
    this.buttonTargets.forEach((button) => {
      button.setAttribute("aria-pressed", String(button.dataset.mode === current))
    })
  }
}
