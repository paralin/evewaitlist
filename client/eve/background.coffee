Meteor.startup =>
  if !CCPEVE?
    return

  pathArray = window.location.href.split '/'
  webAddress = pathArray[0]+"//"+pathArray[2]+"/"

  if !Session.get("hostHash")?
    Session.set("hostHash", Random.id())

  Tracker.autorun ->
    hash = Session.get("hostHash")
    Meteor.subscribe "igbdata", hash

  Meteor.subscribe "waitlists"

  Tracker.autorun ->
    trustStatus = TrustStatus.findOne()
    hasTrust = trustStatus? && trustStatus.status
    if Session.get("hasTrust") isnt hasTrust
      Session.set("hasTrust", hasTrust)  #    Session.set("hostHash", hostHash)

  updateRequest = ()->
    HTTP.get webAddress+"background/update", {headers: {ident: Session.get("hostHash")}}, (err, res)->
      if err?
        console.log err
        return
  setInterval(updateRequest, 3000)
  updateRequest()
