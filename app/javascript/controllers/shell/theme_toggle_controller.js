import { Controller } from "@hotwired/stimulus"

const MODES = ["light", "dark", "system"]

// The studio's appearance menu. The gem's dropdown mounts its content on <body>, outside this element, so a menu item cannot
// carry `data-action="chadcn--theme#setDark"`: the menu announces the pick (`chadcn--dropdown-menu:value-change`, bubbling to
// window) and `choose` forwards it to the `chadcn--theme` controller on this element. The checked item is mirrored into the
// menu's inert <template> (cloned on every open) from `data-theme` on <html>, so it is right whichever path changed the scheme
// (a pick, another instance's `changed` event, another tab's `storage`) and whatever order the two controllers register in.
export default class extends Controller {
  #observer = new MutationObserver(() => this.sync())

  connect() {
    this.#observer.observe(document.documentElement, { attributes: true, attributeFilter: ["data-theme"] })
    this.sync()
  }

  disconnect() {
    this.#observer.disconnect()
  }

  choose(event) {
    const mode = event.detail?.value
    if (!MODES.includes(mode) || !this.#ownsItem(event.target)) return

    this.#theme?.[`set${mode[0].toUpperCase()}${mode.slice(1)}`]()
  }

  sync() {
    const current = document.documentElement.dataset.theme || "system"
    this.#items.forEach((item) => {
      item.setAttribute("aria-checked", String(item.getAttribute("data-chadcn--dropdown-menu-value") === current))
    })
  }

  get #theme() {
    return this.application.getControllerForElementAndIdentifier(this.element, "chadcn--theme")
  }

  // The menu is a <template> inside this element until it opens, then a clone on <body> (its items keep `data-testid`).
  get #items() {
    const template = this.element.querySelector("template")
    return template ? template.content.querySelectorAll("[role=menuitemradio]") : []
  }

  #ownsItem(item) {
    return this.element.querySelector("template")?.content.querySelector(`[data-testid="${item.dataset.testid}"]`) !== null
  }
}
