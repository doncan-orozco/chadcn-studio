import { Controller } from "@hotwired/stimulus"

// Hands a click to a control elsewhere on the page: submits the form of a field, or clicks a button. The generation
// status sits outside the prompt form and the Brand group's dialog trigger, and a streamed fragment cannot carry a
// form's CSRF token, and the Brand trigger is rendered by the gem (no outlet or event can reach it, so the selector value is a documented deviation from stimulus R6), so its "Try again" and "Pick a primary color" forward to the controls that already exist. The
// element it sits on is a real button or link; a missing target leaves it a no-op.
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
      target.click()
    }
  }
}
