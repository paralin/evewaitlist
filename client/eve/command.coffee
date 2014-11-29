Template.command.helpers
  "fleet": ->
    wait = Waitlists.findOne()
    return if !wait?
    commander = Characters.findOne({_id: wait.commander})
    resp = {
      _id: wait._id
      counts: wait.stats
      fc:
        name: commander.name
        avatar: "https://image.eveonline.com/Character/#{commander._id}_128.jpg"
        id: commander._id
    }
    if wait.booster?
      booster = Characters.findOne {_id: wait.booster}
      if booster?
        resp["booster"] =
          name: booster.name
          avatar: "https://image.eveonline.com/Character/#{booster._id}_128.jpg"
          id: booster._id
    if wait.manager?
      manager = Characters.findOne {_id: wait.manager}
      if manager?
        resp["manager"] =
          name: manager.name
          avatar: "https://image.eveonline.com/Character/#{manager._id}_128.jpg"
          id: manager._id
    resp
  "isCommander": ->
    wait = Waitlists.findOne()
    return false if !wait?
    wait.commander is (Session.get("me"))._id
  "nisCommander": ->
    wait = Waitlists.findOne()
    return true if !wait?
    wait.commander isnt (Session.get("me"))._id
  "char": (i)->
    search = null
    search = logi if i is 0
    search = dps if i is 1
    if search?
      return Characters.find {"fits": {$elemMatch: {primary: true, shipid: {$in: search}}}, "waitlist": Waitlists.findOne()._id}
    else
      return Characters.find {"fits": {$elemMatch: {primary: true, shipid: {$not: {$in: _.union(logi, dps)}}}}, "waitlist": Waitlists.findOne()._id}
  "getFitShiptype": ->
    primary = _.findWhere @fits, {primary: true}
    return "unknown" if !primary?
    typeids[primary.shipid+""]
  "pboost": ->
    Characters.find {roles: "booster", active: true}
  "pmanager": ->
    wait = Waitlists.findOne()
    return [] if !wait?
    Characters.find {roles: "manager", active: true, _id: {$ne: wait.commander}}
Template.command.events
  "click #fcName": (e)->
    CCPEVE.showInfo 1377, @fc.id
  "click #boosterName": (e)->
    if @booster?
      CCPEVE.showInfo 1377, @booster.id
  "click #managerName": (e)->
    if @manager?
      CCPEVE.showInfo 1377, @manager.id
  "click .closeWaitlist": (e)->
    Meteor.call "closeWaitlist", Session.get("hostHash"), (err)->
      if err?
        $.pnotify
          title: "Can't Close Waitlist"
          text: err.reason
          type: "error"
  "click .openWaitlist": (e)->
    Meteor.call "openWaitlist", Session.get("hostHash"), (err)->
      if err?
        $.pnotify
          title: "Can't Open Waitlist"
          text: err.reason
          type: "error"
  "click .follower-name": (e)->
    e.preventDefault()
    CCPEVE.showInfo 1377, @_id
  "click .follower-username": (e)->
    e.preventDefault()
    primary = _.findWhere @fits, {primary: true}
    return if !primary?
    CCPEVE.showFitting primary.dna
  "click .delWaitlist": (e)->
    e.preventDefault()
    Meteor.call "deleteFromWaitlist", Session.get("hostHash"), @_id, false, (err)->
      if err?
        $.pnotify
          title: "Can't Remove"
          text: err.reason
          type: "error"
  "click .delMail": (e)->
    e.preventDefault()
    id = @_id
    CCPEVE.sendMail id, "Hello, TVP Pilot!", rejectMail
    Meteor.call "deleteFromWaitlist", Session.get("hostHash"), @_id, false, (err)->
      if err?
        $.pnotify
          title: "Can't Remove"
          text: err.reason
          type: "error"
      else
        CCPEVE.sendMail id, "Hello, TVP Pilot!", rejectMail
  "click .sendInv": (e)->
    e.preventDefault()
    id = @_id
    Meteor.call "deleteFromWaitlist", Session.get("hostHash"), @_id, true, (err)->
      if err?
        $.pnotify
          title: "Can't Accept"
          text: err.reason
          type: "error"
      else
        CCPEVE.inviteToFleet id
  "click .setBoost": (e)->
    e.preventDefault()
    id = @_id
    Meteor.call "setBooster", Session.get("hostHash"), id, (err)->
      if err?
        $.pnotify
          title: "Can't Set Booster"
          text: err.reason
          type: "error"
  "click .removeBoost": (e)->
    e.preventDefault()
    id = @_id
    Meteor.call "removeBooster", Session.get("hostHash"), (err)->
      if err?
        $.pnotify
          title: "Can't Remove Booster"
          text: e.reason
          type: "error"
  "click .setManager": (e)->
    e.preventDefault()
    id = @_id
    Meteor.call "setManager", Session.get("hostHash"), id, (err)->
      if err?
        $.pnotify
          title: "Can't Set Manager"
          text: err.reason
          type: "error"
  "click .removeManager": (e)->
    e.preventDefault()
    id = @_id
    Meteor.call "removeManager", Session.get("hostHash"), (err)->
      if err?
        $.pnotify
          title: "Can't Remove Manager"
          text: e.reason
          type: "error"
