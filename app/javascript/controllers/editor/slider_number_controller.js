import { Controller } from "@hotwired/stimulus"

// A number box beside a `chadcn--slider` and the slider's value in its label. The slider keeps owning the value (and the
// preview wiring that listens to its events); this controller only mirrors it into the box and the label (and into the
// thumb's `aria-valuetext`, so it reads as a domain value). When a value is typed it walks the slider from where it is to
// the typed step with the slider's own keyboard steps (PageUp/PageDown = 10 steps, ArrowUp/ArrowDown = 1 step), so the
// preview and derivation controllers hear the same `value-change` and `value-commit` events as for a drag.
const PAGE_STEPS = 10

export default class extends Controller {
  static targets = ["slider", "input", "readout"]
  static values = { unit: String }

  connect() {
    const thumb = this.#thumb
    if (thumb) this.#describe(thumb, thumb.getAttribute("aria-valuenow"))
  }

  // `chadcn--slider:value-change`: the slider moved.
  mirror(event) {
    const [value] = event.detail.value
    this.inputTarget.value = value
    this.readoutTarget.textContent = `${value}${this.unitValue}`
    const thumb = this.#thumb
    if (thumb) this.#describe(thumb, value)
  }

  disconnect() {
    cancelAnimationFrame(this.walkFrame)
  }

  // The box `change`: the typed value, clamped to the slider's range and snapped to its step. The walk runs on the next
  // frame, after the browser's own focus move (Tab), because the slider's keyboard handler focuses its thumb: focus goes
  // back to wherever it was so typing never pulls it out of the box.
  type() {
    cancelAnimationFrame(this.walkFrame)
    this.walkFrame = requestAnimationFrame(() => {
      const thumb = this.#thumb
      const delta = thumb ? this.#delta(thumb) : 0
      if (delta !== 0) {
        const held = document.activeElement
        this.#walk(thumb, delta)
        if (held && held !== thumb && held !== document.body && held.isConnected) held.focus({ preventScroll: true })
      }
      this.#restore()
    })
  }

  // Steps from the slider's value to the typed one (0 when the box is empty or not a number).
  #delta(thumb) {
    if (this.inputTarget.value.trim() === "") return 0

    const typed = Number(this.inputTarget.value)
    if (!Number.isFinite(typed)) return 0

    const min = Number(this.inputTarget.min)
    const max = Number(this.inputTarget.max)
    const step = Number(this.inputTarget.step) || 1
    // The stored value can sit off the step grid (0.625 with step 0.05): the first press lands on the next grid point.
    const raw = (Number(thumb.getAttribute("aria-valuenow")) - min) / step
    const current = Math.abs(raw - Math.round(raw)) < 1e-6 ? Math.round(raw) : raw
    const target = Math.round((Math.min(Math.max(typed, min), max) - min) / step)
    return target - current
  }

  #walk(thumb, delta) {
    const [page, single] = delta > 0 ? ["PageUp", "ArrowUp"] : ["PageDown", "ArrowDown"]
    let presses = Math.ceil(Math.abs(delta))
    // Off the grid the slider's first press, whatever the key, only moves to the next grid point: spend a single step on it.
    if (!Number.isInteger(delta)) {
      this.#press(thumb, single)
      presses -= 1
    }
    for (let index = 0; index < Math.floor(presses / PAGE_STEPS); index++) this.#press(thumb, page)
    for (let index = 0; index < presses % PAGE_STEPS; index++) this.#press(thumb, single)
  }

  get #thumb() {
    return this.sliderTarget.querySelector("[role=slider]")
  }

  #describe(thumb, value) {
    thumb.setAttribute("aria-valuetext", `${value}${this.unitValue}`)
  }

  // The box always shows what the slider holds, also after a typed value was clamped or snapped.
  #restore() {
    const thumb = this.#thumb
    if (thumb) this.inputTarget.value = thumb.getAttribute("aria-valuenow")
  }

  #press(thumb, key) {
    thumb.dispatchEvent(new KeyboardEvent("keydown", { key, bubbles: true, cancelable: true }))
  }
}
