# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
# Tom Select is loaded via CDN in the layout, available as window.TomSelect
pin_all_from "app/javascript/controllers", under: "controllers"
