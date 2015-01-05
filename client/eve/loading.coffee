message = "<p class=\"loading-message\">Loading waitlist...</p>"

Template.loading.rendered = ->
  @loading = window.pleaseWait(
    logo: "/images/logo.png"
    backgroundColor: "#7f8c8d"
    loadingHtml: message
  )
  return

Template.loading.destroyed = ->
  @loading.finish()
  return
