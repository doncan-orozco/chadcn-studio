import { Controller } from "@hotwired/stimulus"

// Hands a click to a control elsewhere on the page: submits the form of a field, focuses a text field, or clicks a
// button. The generation status sits outside the prompt form and outside the Brand group's dialog trigger. A streamed
// fragment cannot carry a form's CSRF token, and the trigger is a gem dialog trigger that no outlet or event reaches,
// so the selector value is a documented deviation from stimulus R6. A missing target leaves the button a no-op.
export default class extends Controller {
  static values = { selector: String, method: { type: String, default: "click" } }

  forward(event) {
    const target = document.querySelector(this.selectorValue)
    if (!target) return

    if (this.methodValue === "submit") {
      const form = target.form
      if (!form) return

      event.preventDefault()
      target.focus()
      form.requestSubmit()
    } else {
      event.preventDefault()
      if (this.#isField(target)) target.focus()
      else target.click()
    }
  }

  #isField(element) {
    return element.matches("input, textarea, select")
  }
}
