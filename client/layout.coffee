Template.body.helpers
  isEve: ->
    Session.get "eveClient"
  showLoading: ->
    Session.get "loading"
