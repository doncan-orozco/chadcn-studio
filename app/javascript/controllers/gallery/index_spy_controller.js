import { Controller } from "@hotwired/stimulus"

// Marks the index link of the catalog entry being read: `aria-current="location"` on that link, styled by the view. The
// entry is found from the link's own `#anchor`, so the view stays the single place that names ids. It is the last entry
// whose top has passed the reading line (the top third of the window); at the end of the page it is the last entry, which
// can never reach that line. A link whose entry is not on the page is left alone.
export default class extends Controller {
  static targets = ["link"]

  connect() {
    this.schedule()
  }

  disconnect() {
    if (this.frame) cancelAnimationFrame(this.frame)
    this.frame = null
  }

  // Bound to scroll and resize by the view; one frame at a time.
  schedule() {
    if (this.frame) return
    this.frame = requestAnimationFrame(() => {
      this.frame = null
      this.#mark(this.#current())
    })
  }

  #current() {
    const pairs = this.linkTargets.map((link) => [link, this.#entryFor(link)]).filter(([, entry]) => entry)
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
      if (link === current) link.setAttribute("aria-current", "location")
      else link.removeAttribute("aria-current")
    })
  }

  #entryFor(link) {
    try {
      const anchor = decodeURIComponent(link.hash.slice(1))
      return anchor === "" ? null : document.getElementById(anchor)
    } catch (error) {
      if (error instanceof URIError) return null
      throw error
    }
  }
}
