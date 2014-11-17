Meteor.startup ->
  Tracker.autorun ->
    page = Session.get("igbpage")
    if !page? || (page.canView? && !page.canView())
      Session.set "igbpage", "waitlist"
    else
      page = Pages[page]
      if page.subscriptions?
        for sub in page.subscriptions
          Meteor.subscribe sub
Template.eveClient.helpers
  "trust": ->
    JSON.stringify Characters.findOne()
  "character": ->
    Characters.findOne()
  "avatar": (character)->
    "" if !character?
    "https://image.eveonline.com/Character/#{character.charId}_64.jpg"
  "activeTemplate": ->
    Pages[Session.get "igbpage"].template
  "activePage": ->
    Pages[Session.get "igbpage"]
  "canView": (page)->
    Pages[page].canView? and Pages[page].canView()
Template.eveClient.events
  "click #destoToStaging": (e)->
    e.preventDefault()
    CCPEVE.setDestination 30000142
  "click #joinChatChannel": (e)->
    e.preventDefault()
    CCPEVE.joinChannel "The Valhalla Project"
  "click .gotoLink": (e)->
    e.preventDefault()
    Session.set "igbpage", e.currentTarget.attributes["page-target"].value
  "click .da": (e)->
    e.preventDefault()
