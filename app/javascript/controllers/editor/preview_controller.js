import { Controller } from "@hotwired/stimulus"

// The live preview of the theme editor (stimulus R14, theme-science R6). It only sets CSS custom properties on the preview
// root and toggles its `dark` class: while a slider moves it formats ONE oklch string from L, C and H (or one rem length);
// everything else (foregrounds, ring, charts...) arrives from the server as a whole palette after the slider is released.
// Wrapper of the editor: the preview root is a target, the toolbar form posts the inputs to /derivations.
const DECIMALS = 3
const formatNumber = (value) => Number(Number(value).toFixed(DECIMALS)).toString()

export default class extends Controller {
  static targets = ["root", "palette", "primaryField", "radiusField", "lightness", "chroma", "hue", "radius", "form", "derive", "refresh"]
  static values = { mode: { type: String, default: "light" } }

  disconnect() {
    cancelAnimationFrame(this.animationFrame)
    this.animationFrame = null
    this.pendingChannel = null
    this.palette = null
    this.applied = null
  }

  // The palette source (server-rendered, replaced by the derivation stream) holds both modes' variables.
  paletteTargetConnected(element) {
    try {
      this.palette = { light: JSON.parse(element.dataset.light), dark: JSON.parse(element.dataset.dark) }
    } catch {
      return
    }
    this.#apply()
  }

  modeValueChanged() {
    this.#apply()
  }

  // `chadcn--slider:value-change`: the slider moved, nothing is requested.
  slide(event) {
    this.pendingChannel = event.params.channel
    this.animationFrame ||= requestAnimationFrame(() => {
      this.animationFrame = null
      this.#flush()
    })
  }

  // `chadcn--slider:value-commit` and field `change`: the inputs are final, ask the server to derive. A keyboard step
  // announces the commit before the slider has written its new value, so the request waits for the next frame.
  commit() {
    cancelAnimationFrame(this.animationFrame)
    this.animationFrame = requestAnimationFrame(() => {
      this.animationFrame = null
      this.#flush()
      this.dispatch("change", { detail: { mode: this.modeValue } })
      this.formTarget.requestSubmit(this.deriveTarget)
    })
  }

  // Enter in an override field confirms it (the field's `change` posts) instead of submitting the Save form.
  confirm(event) {
    event.target.dispatchEvent(new Event("change", { bubbles: true }))
  }

  // `chadcn--switch:checked-change`: the dark switch of the editor toggles the preview root only.
  mode(event) {
    this.modeValue = event.detail.checked ? "dark" : "light"
  }

  // `editor--color:picked`: a color chosen in the native picker, already converted to oklch.
  pick(event) {
    this.primaryFieldTarget.value = event.detail.primary
    this.#setVariable("--primary", event.detail.primary)
    this.dispatch("change", { detail: { mode: this.modeValue } })
    this.formTarget.requestSubmit(this.refreshTarget)
  }

  #flush() {
    const channel = this.pendingChannel
    this.pendingChannel = null
    if (channel === "radius") this.#previewRadius()
    else if (channel) this.#previewPrimary()
  }

  #previewPrimary() {
    if (!this.hasLightnessTarget || !this.hasChromaTarget || !this.hasHueTarget) return
    const color = `oklch(${formatNumber(this.#sliderValue(this.lightnessTarget))} ${formatNumber(this.#sliderValue(this.chromaTarget))} ${formatNumber(this.#sliderValue(this.hueTarget))})`
    this.primaryFieldTarget.value = color
    this.#setVariable("--primary", color)
  }

  #previewRadius() {
    if (!this.hasRadiusTarget) return
    const radius = `${formatNumber(this.#sliderValue(this.radiusTarget))}rem`
    this.radiusFieldTarget.value = radius
    this.#setVariable("--radius", radius)
  }

  #sliderValue(slider) {
    return slider.querySelector("[role=slider]").getAttribute("aria-valuenow")
  }

  #apply() {
    if (!this.palette || !this.hasRootTarget) return
    const dark = this.modeValue === "dark"
    this.rootTarget.classList.toggle("dark", dark)
    const variables = this.palette[dark ? "dark" : "light"]
    ;(this.applied || []).filter((name) => !(name in variables)).forEach((name) => this.rootTarget.style.removeProperty(name))
    Object.entries(variables).forEach(([name, value]) => this.#setVariable(name, value))
    this.applied = Object.keys(variables)
  }

  #setVariable(name, value) {
    this.rootTarget.style.setProperty(name, value)
  }
}
