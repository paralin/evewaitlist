Meteor.startup ->
  if !Session.get("language")?
    Session.set("language", "en")

  Tracker.autorun ->
    language = Session.get "language"
    Session.set "loading", true
    TAPi18n.setLanguage(language).done(->
      Session.set "loading", false
      return
    ).fail (error_message) ->
      Session.set "loading", false
      if language isnt "en"
        Session.set("language", "en")
      alert "Sorry, we can't load the translation data for you. #{error_message}"
      return
    return
