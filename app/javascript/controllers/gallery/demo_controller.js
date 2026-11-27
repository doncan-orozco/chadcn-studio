import { Controller } from "@hotwired/stimulus"

// A gallery demo is a specimen: its `#` links (and links to an anchor the demo does not hold) must not scroll the page to
// the top or away from the entry being read. Links to an anchor inside the demo still work. The links keep their href, so they
// stay focusable and announced as links; only the jump is stopped.
export default class extends Controller {
  stay(event) {
    if (event.defaultPrevented || !(event.target instanceof Element)) return

    const link = event.target.closest("a[href^='#']")
    if (!link || !this.element.contains(link)) return

    const id = link.getAttribute("href").slice(1)
    if (id && this.element.querySelector(`#${CSS.escape(id)}`)) return

    event.preventDefault()
  }
}
