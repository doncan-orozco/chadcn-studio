import { Controller } from "@hotwired/stimulus"
import { formatCss, parse } from "culori"

// The grammar Themes::Oklch.parse reads, and nothing more (app/concepts/themes/oklch.rb HEX, PATTERN and ranges): a hex
// with or without "#", "#rgb", or oklch(L C H [/ A%]). Anything else the contract rejects on change, so the swatch must not
// claim to have understood it. Display only: Ruby validates and derives (architecture R13, theme-science R6).
const HEX = /^\s*(?:#?([0-9a-f]{6})|#([0-9a-f]{3}))\s*$/i
const NUMBER = String.raw`-?\d+(?:\.\d+)?|-?\.\d+`
const OKLCH = new RegExp(String.raw`^\s*oklch\(\s*(${NUMBER})\s+(${NUMBER})\s+(${NUMBER})(?:\s*/\s*(${NUMBER})%)?\s*\)\s*$`, "i")
const within = (value, min, max) => value === undefined || (value >= min && value <= max)

function readable(text) {
  const hex = HEX.exec(text)
  if (hex) return parse(`#${hex[1] || hex[2]}`)

  const match = OKLCH.exec(text)
  if (!match) return undefined

  const [lightness, chroma, hue, alpha] = match.slice(1).map((number) => (number === undefined ? undefined : Number(number)))
  return within(lightness, 0, 1) && within(chroma, 0, 0.4) && within(hue, 0, 360) && within(alpha, 0, 100) ? parse(text) : undefined
}

// Paints the swatch beside an override field with the color being typed, as the user types (the server only sees it on
// change). A value the server would not read falls back to the derived swatch, drawn with a dashed border so it does not
// look like an empty field; clearing the field shows what the rule gives.
export default class extends Controller {
  static targets = ["input", "swatch"]

  connect() {
    this.paint()
  }

  paint() {
    const typed = this.inputTarget.value.trim()
    const color = typed ? readable(typed) : undefined

    this.swatchTarget.style.cssText = color ? `background-color: ${formatCss(color)}` : this.swatchTarget.dataset.derived || ""
    this.swatchTarget.dataset.state = color ? "typed" : typed ? "invalid" : "derived"
  }
}
