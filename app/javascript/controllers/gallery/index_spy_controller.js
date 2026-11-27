import { Controller } from "@hotwired/stimulus"

// Marks the index link of the catalog entry being read: `aria-current="location"` on that link, styled by the component. The
// entries are targets, matched to links by the link's `#fragment` against the entry's id, so the markup stays the single place that names ids. It is the last entry
// whose top has passed the reading line (the top third of the window); at the end of the page it is the last entry, which
// can never reach that line. A link whose entry is not on the page is left alone.
export default class extends Controller {
  static targets = ["link", "entry"]

  connect() {
    this.schedule()
  }

  disconnect() {
    if (this.frame) cancelAnimationFrame(this.frame)
    this.frame = null
    this.linkTargets.forEach((link) => link.removeAttribute("aria-current"))
  }

  // Bound to scroll and resize by the component; one frame at a time.
  schedule() {
    if (this.frame) return
    this.frame = requestAnimationFrame(() => {
      this.frame = null
      this.#mark(this.#current())
    })
  }

  #current() {
    const entries = new Map(this.entryTargets.map((entry) => [entry.id, entry]))
    const pairs = this.linkTargets
      .map((link) => [link, entries.get(link.getAttribute("href").slice(1))])
      .filter(([, entry]) => entry)
    if (pairs.length === 0) return null
    if (this.#atEnd()) return pairs.at(-1)[0]
    const line = window.innerHeight / 3
    const passed = pairs.filter(([, entry]) => entry.getBoundingClientRect().top <= line)
    return (passed.at(-1) || pairs[0])[0]
  }

  #atEnd() {
    const root = document.documentElement
    return window.scrollY > 0 && window.innerHeight + window.scrollY >= root.scrollHeight - 2
  }

  #mark(current) {
    this.linkTargets.forEach((link) => {
      const marked = link.getAttribute("aria-current") === "location"
      if (link === current && !marked) link.setAttribute("aria-current", "location")
      else if (link !== current && link.hasAttribute("aria-current")) link.removeAttribute("aria-current")
    })
  }
}
