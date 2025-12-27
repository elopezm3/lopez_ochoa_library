import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    placeholder: String
  }

  connect() {
    // Wait for TomSelect to be available (loaded from CDN)
    if (typeof window.TomSelect !== 'undefined') {
      this.initializeTomSelect()
    } else {
      // If not loaded yet, wait a bit and try again
      setTimeout(() => this.initializeTomSelect(), 100)
    }
  }

  initializeTomSelect() {
    const options = {
      placeholder: this.placeholderValue || "Seleccione una opción...",
      allowEmptyOption: true,
      plugins: ['clear_button']
    }

    this.tomSelect = new window.TomSelect(this.element, options)
  }

  disconnect() {
    if (this.tomSelect) {
      this.tomSelect.destroy()
    }
  }
}

