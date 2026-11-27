import { Controller } from "@hotwired/stimulus"
import { formatHex } from "culori"

// The brand color as a hex, nothing else (theme-science R6): the picker and the Hex field show the current primary and
// announce a chosen or typed color as "#rrggbb"; the server converts it to oklch and derives the palette.
const HEX = /^#?([0-9a-f]{6}|[0-9a-f]{3})$/i

const normalize = (text) => {
  const digits = HEX.exec(text.trim())?.[1]
  if (!digits) return null
  return `#${(digits.length === 3 ? [...digits].map((digit) => digit + digit).join("") : digits).toLowerCase()}`
}

export default class extends Controller {
  static targets = ["input", "hex", "error"]
  static values = { primary: String }

  primaryValueChanged() {
    const hex = formatHex(this.primaryValue)
    if (hex) this.inputTarget.value = hex
  }

  // The Hex field is rendered by the server with the exact hex the person typed (rounding through oklch would lose it), so
  // the picker follows the primary and the field is only written here by what the person does.
  pick() {
    this.hexTarget.value = this.inputTarget.value
    this.#invalid(false)
    this.#announce(this.inputTarget.value)
  }

  // A cleared field is not an error, it changes nothing.
  typeHex() {
    if (this.hexTarget.value.trim() === "") return this.#invalid(false)

    const hex = normalize(this.hexTarget.value)
    this.#invalid(!hex)
    if (!hex) return

    this.hexTarget.value = hex
    this.inputTarget.value = hex
    this.#announce(hex)
  }

  #announce(hex) {
    this.dispatch("picked", { detail: { primary: hex } })
  }

  #invalid(invalid) {
    this.errorTarget.hidden = !invalid
    this.hexTarget.setAttribute("aria-invalid", String(invalid))
  }
}
