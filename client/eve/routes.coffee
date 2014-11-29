@Pages =
  waitlist:
    title: "Waitlist"
    template: "waitlist"
  logifits:
    title: "Logistics Fits"
    template: "fits"
    subscriptions: ["fits"]
  hybridfits:
    title: "Hybrid Fits"
    template: "fits"
    subscriptions: ["fits"]
  projfits:
    title: "Projectile Fits"
    template: "fits"
    subscriptions: ["fits"]
  lazerfits:
    title: "Lazer Fits"
    template: "fits"
    subscriptions: ["fits"]
  missilefits:
    title: "Missile Fits"
    template: "fits"
    subscriptions: ["fits"]
  insurance:
    title: "Insurance Guide"
    template: "insurance"
  eventlog:
    title: "Event Log"
    template: "events"
    canView: ->
      character = Session.get "me"
      character? and character.roles? and _.contains character.roles, "events"
    subscriptions: ["eventlog"]
  admin:
    title: "Admin"
    template: "admin"
    canView: ->
      character = Session.get "me"
      character? and character.roles? and _.contains character.roles, "admin"
    onView: ->
      Meteor.subscribe "admin", Session.get("hostHash")
  profile:
    title: "Character Profile"
    template: "profile"
    canView: ->
      character = Session.get "me"
      character? and character.roles? and _.contains character.roles, "admin"
    onView: ->
      Meteor.subscribe "admin", Session.get("hostHash")
      Meteor.subscribe "profile", Session.get("hostHash"), parseInt Session.get("profilechar")
  command:
    title: "Waitlist Command"
    template: "command"
    canView: ->
      character = Session.get "me"
      character? and character.roles? and (("manager" in character.roles) or ("command" in character.roles))
    onView: ->
      Meteor.subscribe "command", Session.get("hostHash")
