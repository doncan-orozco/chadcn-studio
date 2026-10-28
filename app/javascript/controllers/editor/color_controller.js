import { Controller } from "@hotwired/stimulus"
import { formatHex, oklch } from "culori"

// Hex <-> oklch conversion for the native color input, nothing else (theme-science R6): the picker only shows the current
// primary and announces the picked one as an oklch string; the server derives the palette.
const number = (value) => Number(Number(value).toFixed(3)).toString()

export default class extends Controller {
  static targets = ["input"]
  static values = { primary: String }

  primaryValueChanged() {
    const hex = formatHex(this.primaryValue)
    if (hex) this.inputTarget.value = hex
  }

  pick() {
    const color = oklch(this.inputTarget.value)
    if (!color) return
    this.dispatch("picked", { detail: { primary: `oklch(${number(color.l)} ${number(color.c)} ${number(color.h || 0)})` } })
  }
}
