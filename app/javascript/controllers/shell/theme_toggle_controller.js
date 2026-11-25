import { Controller } from "@hotwired/stimulus"

// Mirrors the chosen color scheme (`data-theme` on <html>, written by the gem's chadcn--theme controller) into `aria-pressed`
// on the Light / Dark / System buttons. It observes the attribute itself, so it is right whatever order the two controllers
// register in and whichever path changed the scheme (a click, another instance's `changed` event, another tab's `storage`).
export default class extends Controller {
  static targets = ["button"]

  #observer = new MutationObserver(() => this.sync())

  connect() {
    this.#observer.observe(document.documentElement, { attributes: true, attributeFilter: ["data-theme"] })
    this.sync()
  }

  disconnect() {
    this.#observer.disconnect()
  }

  sync() {
    const current = document.documentElement.dataset.theme || "system"
    this.buttonTargets.forEach((button) => {
      button.setAttribute("aria-pressed", String(button.dataset.mode === current))
    })
  }
}
