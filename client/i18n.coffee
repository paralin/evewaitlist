Meteor.startup ->
  if !Session.get("language")?
    Session.set("language", "en")

  Tracker.autorun ->
    language = Session.get "language"
    TAPi18n.setLanguage(language).done(->
      return
    ).fail (error_message) ->
      if language isnt "en"
        Session.set("language", "en")
      alert "Sorry, we can't load the translation data for you. #{error_message}"
      return
    return
