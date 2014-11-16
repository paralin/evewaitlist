Template.body.helpers
  isEve: ->
    true or Session.get "eveClient"
