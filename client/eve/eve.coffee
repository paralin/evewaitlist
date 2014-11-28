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
      page.onView() if page.onView?
Template.eveClient.helpers
  "character": ->
    Characters.findOne({hostid: Session.get("hostHash")})
  "avatar": (character)->
    return "" if !character?
    "https://image.eveonline.com/Character/#{character._id}_64.jpg"
  "activeTemplate": ->
    Pages[Session.get "igbpage"].template
  "activePage": ->
    Pages[Session.get "igbpage"]
  "canView": (page)->
    Pages[page].canView? and Pages[page].canView()
  "hasTrust": ->
    Session.get("hasTrust")
Template.eveClient.events
  "click #destoToStaging": (e)->
    e.preventDefault()
    CCPEVE.setDestination Settings.findOne({_id: "incursion"}).sysid
  "click #joinChatChannel": (e)->
    e.preventDefault()
    CCPEVE.joinChannel "The Valhalla Project"
  "click .gotoLink": (e)->
    e.preventDefault()
    Session.set "igbpage", e.currentTarget.attributes["page-target"].value
  "click .da": (e)->
    e.preventDefault()
Template.requestTrust.events
  "click .requestTrustButton": ->
    pathArray = window.location.href.split '/'
    webAddress = pathArray[0]+"//"+pathArray[2]+"/"
    CCPEVE.requestTrust(webAddress+"*")
