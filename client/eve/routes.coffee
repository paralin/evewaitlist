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
      character = Characters.findOne()
      character? and character.roles? and _.contains character.roles, "events"
    subscriptions: ["eventlog"]
