import { Controller } from "@hotwired/stimulus"

// Mirrors the chosen color scheme (`data-theme` on <html>, set by the gem's chadcn--theme controller) into `aria-pressed`
// on the Light / Dark / System buttons, so the active one is announced and styled as pressed.
// Wired in the view to `chadcn--theme:changed` and `storage@window`, because the gem's cross-tab #follow does not dispatch.
export default class extends Controller {
  static targets = ["button"]

  connect() {
    this.sync()
  }

  // Runs after the gem's controller has written `data-theme` (connect order, its `changed` event and its window `storage` listener all precede this call).
  sync() {
    const current = document.documentElement.dataset.theme || "system"
    this.buttonTargets.forEach((button) => {
      button.setAttribute("aria-pressed", String(button.dataset.mode === current))
    })
  }
}
