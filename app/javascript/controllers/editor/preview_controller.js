import { Controller } from "@hotwired/stimulus"

// The live preview of the theme editor (stimulus R14, theme-science R6). It only sets CSS custom properties on the preview
// root and toggles its `dark` class: while a slider moves it formats ONE oklch string from L, C and H (or one rem length);
// everything else (foregrounds, ring, charts...) arrives from the server as a whole palette after the slider is released.
// Wrapper of the editor: the preview root is a target, the toolbar form posts the inputs to /derivations.
const DECIMALS = 3
const number = (value) => Number(Number(value).toFixed(DECIMALS)).toString()

export default class extends Controller {
  static targets = ["root", "palette", "primaryField", "radiusField", "lightness", "chroma", "hue", "radius", "form", "derive", "refresh"]
  static values = { mode: { type: String, default: "light" } }

  disconnect() {
    cancelAnimationFrame(this.frame)
    this.frame = null
    this.palette = null
  }

  // The palette source (server-rendered, replaced by the derivation stream) holds both modes' variables.
  paletteTargetConnected(element) {
    this.palette = { light: JSON.parse(element.dataset.light), dark: JSON.parse(element.dataset.dark) }
    this.#apply()
  }

  modeValueChanged() {
    this.#apply()
  }

  // `chadcn--slider:value-change`: the slider moved, nothing is requested.
  slide(event) {
    this.pending = event.params.channel
    this.frame ||= requestAnimationFrame(() => {
      this.frame = null
      this.#preview(this.pending)
    })
  }

  // `chadcn--slider:value-commit` and field `change`: the inputs are final, ask the server to derive.
  commit() {
    this.formTarget.requestSubmit(this.deriveTarget)
  }

  // Enter in an override field confirms it (the field's `change` posts) instead of submitting the Save form.
  confirm(event) {
    event.target.blur()
  }

  // `chadcn--switch:checked-change`: the dark switch of the editor toggles the preview root only.
  mode(event) {
    this.modeValue = event.detail.checked ? "dark" : "light"
  }

  // `editor--color:picked`: a color chosen in the native picker, already converted to oklch.
  pick(event) {
    this.primaryFieldTarget.value = event.detail.primary
    this.#setVariable("--primary", event.detail.primary)
    this.formTarget.requestSubmit(this.refreshTarget)
  }

  #preview(channel) {
    if (channel === "radius") return this.#previewRadius()
    this.#previewPrimary()
  }

  #previewPrimary() {
    if (!this.hasLightnessTarget || !this.hasChromaTarget || !this.hasHueTarget) return
    const color = `oklch(${number(this.#sliderValue(this.lightnessTarget))} ${number(this.#sliderValue(this.chromaTarget))} ${number(this.#sliderValue(this.hueTarget))})`
    this.primaryFieldTarget.value = color
    this.#setVariable("--primary", color)
  }

  #previewRadius() {
    if (!this.hasRadiusTarget) return
    const radius = `${number(this.#sliderValue(this.radiusTarget))}rem`
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
    Object.entries(this.palette[dark ? "dark" : "light"]).forEach(([name, value]) => this.#setVariable(name, value))
  }

  #setVariable(name, value) {
    this.rootTarget.style.setProperty(name, value)
  }
}
