import { Controller } from "@hotwired/stimulus"

// A number box beside a `chadcn--slider` and the slider's value in its label. The slider keeps owning the value (and the
// preview wiring that listens to its events); this controller only mirrors it into the box and the label, and when a
// value is typed it walks the slider there with the slider's own keyboard steps (Home, PageUp = 10 steps, Right = 1 step),
// so the preview and derivation controllers hear the same `value-change` and `value-commit` events as for a drag.
const PAGE_STEPS = 10

export default class extends Controller {
  static targets = ["slider", "input", "readout"]
  static values = { unit: String }

  // `chadcn--slider:value-change`: the slider moved.
  mirror(event) {
    const [value] = event.detail.value
    this.inputTarget.value = value
    this.readoutTarget.textContent = `${value}${this.unitValue}`
  }

  // The box `change`: the typed value, clamped to the slider's range and snapped to its step.
  type() {
    if (this.inputTarget.value.trim() === "") return this.#restore()

    const { min, max, step } = this.#range
    const typed = Number(this.inputTarget.value)
    if (!Number.isFinite(typed)) return this.#restore()

    const steps = Math.round((Math.min(Math.max(typed, min), max) - min) / step)
    const thumb = this.sliderTarget.querySelector("[role=slider]")
    this.#press(thumb, "Home")
    for (let page = 0; page < Math.floor(steps / PAGE_STEPS); page++) this.#press(thumb, "PageUp")
    for (let single = 0; single < steps % PAGE_STEPS; single++) this.#press(thumb, "ArrowRight")
    this.#restore()
  }

  // Enter in the box confirms it instead of submitting the Save form.
  confirm(event) {
    event.preventDefault()
    this.type()
  }

  get #range() {
    const thumb = this.sliderTarget.querySelector("[role=slider]")
    return { min: Number(thumb.getAttribute("aria-valuemin")), max: Number(thumb.getAttribute("aria-valuemax")), step: Number(this.inputTarget.step) }
  }

  // The box always shows what the slider holds, also after a typed value was clamped or snapped.
  #restore() {
    this.inputTarget.value = this.sliderTarget.querySelector("[role=slider]").getAttribute("aria-valuenow")
  }

  #press(thumb, key) {
    thumb.dispatchEvent(new KeyboardEvent("keydown", { key, bubbles: true, cancelable: true }))
  }
}
