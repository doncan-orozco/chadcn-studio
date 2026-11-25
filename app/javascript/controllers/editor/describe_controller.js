import { Controller } from "@hotwired/stimulus"

// Keyboard bridge for the gem's force-mounted, non-modal dialog (UPSTREAM chadcn: its focus scope is created while closed,
// so opening never moves focus into the content and the next Tab dismisses it; closing never returns focus either).
// On open it focuses the prompt once the closed state's `hidden` has lifted; on close it gives focus back to the trigger
// when it was lost to the body or left inside the panel.
export default class extends Controller {
  static values = { prompt: String, panel: String }

  // `chadcn--dialog:open-change`: the dialog opened or closed.
  toggled(event) {
    cancelAnimationFrame(this.frame)
    if (event.detail.open) {
      this.frame = requestAnimationFrame(() => document.getElementById(this.promptValue)?.focus())
    } else {
      const panel = document.getElementById(this.panelValue)
      const active = document.activeElement
      if (active === document.body || panel?.contains(active)) this.#trigger?.focus()
    }
  }

  disconnect() {
    cancelAnimationFrame(this.frame)
  }

  get #trigger() {
    return this.element.querySelector("[aria-haspopup='dialog']")
  }
}
