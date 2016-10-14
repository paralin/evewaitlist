Meteor.startup =>
  pathArray = window.location.href.split '/'
  webAddress = pathArray[0]+"//"+pathArray[2]+"/"

  Tracker.autorun ->
    user = Meteor.user()
    if !user?
      return
    uid = user._id
    Meteor.subscribe "igbdata"
    Session.set "me", Characters.findOne({uid: uid})

  Meteor.subscribe "waitlists"
