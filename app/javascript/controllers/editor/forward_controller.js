import { Controller } from "@hotwired/stimulus"

// Hands a click to a control elsewhere on the page: submits the form of a field, or clicks a button. The generation
// status sits outside the prompt form and the Brand group's dialog trigger, and a streamed fragment cannot carry a
// form's CSRF token, so its "Try again" and "Pick a primary color" forward to the controls that already exist. The
// element it sits on is a real button or link; a missing target leaves it a no-op.
export default class extends Controller {
  static values = { selector: String, method: { type: String, default: "click" } }

  forward(event) {
    const target = document.querySelector(this.selectorValue)
    if (!target) return

    event.preventDefault()
    if (this.methodValue === "submit") target.form?.requestSubmit()
    else target.click()
  }
}
