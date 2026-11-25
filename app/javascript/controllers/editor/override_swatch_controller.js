import { Controller } from "@hotwired/stimulus"
import { formatCss, parse } from "culori"

// Paints the swatch beside an override field with the color being typed, as the user types (the server only sees it on
// change). An unparseable value falls back to the derived swatch, so a half-typed hex never leaves a stale color; clearing
// the field shows what the rule gives. Display only: the server validates and derives (theme-science R6).
export default class extends Controller {
  static targets = ["input", "swatch"]

  connect() {
    this.paint()
  }

  paint() {
    const typed = this.inputTarget.value.trim()
    const color = typed && parse(typed)
    if (color) {
      this.swatchTarget.style.backgroundColor = formatCss(color)
      this.swatchTarget.dataset.state = "typed"
    } else {
      this.swatchTarget.removeAttribute("style")
      this.swatchTarget.style.cssText = this.swatchTarget.dataset.derived || ""
      this.swatchTarget.dataset.state = typed ? "invalid" : "derived"
    }
  }
}
