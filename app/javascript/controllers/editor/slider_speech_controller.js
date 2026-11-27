import { Controller } from "@hotwired/stimulus"

// Gives a `chadcn--slider` thumb a spoken value (`aria-valuetext`): the raw `aria-valuenow` (0.488) is not what the label
// of a brand channel means (49%), so a screen reader or a voice user hears the domain value. Mirrors the slider as it moves;
// owns nothing else (the preview and derivation controllers listen to the same events).
export default class extends Controller {
  static targets = ["slider"]
  static values = { scale: { type: Number, default: 1 }, digits: { type: Number, default: 0 }, unit: String }

  connect() {
    this.#speak(this.#thumb?.getAttribute("aria-valuenow"))
  }

  // `chadcn--slider:value-change`: the slider moved.
  mirror(event) {
    this.#speak(event.detail.value[0])
  }

  get #thumb() {
    return this.sliderTarget.querySelector("[role=slider]")
  }

  #speak(value) {
    const thumb = this.#thumb
    if (!thumb || value === null || value === undefined || value === "") return

    const spoken = Number((Number(value) * this.scaleValue).toFixed(this.digitsValue))
    thumb.setAttribute("aria-valuetext", `${spoken}${this.unitValue}`)
  }
}
