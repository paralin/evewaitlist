types = [{name: "Logistics", id: 0, icon: "fa-fire-extinguisher"}, {name: "Damage", id: 1, icon: "fa-fire"}, {name: "Other", id: 2, icon: "fa-question"}]
Template.command.helpers
  "types": ->
    types
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
    if wait.booster? && wait.booster.length
      booster = Characters.find {_id: {$in: wait.booster}}
      if booster.count()
        resp["booster"] = []
        for boost in booster.fetch()
          resp["booster"].push
            name: boost.name
            avatar: "https://image.eveonline.com/Character/#{boost._id}_128.jpg"
            id: boost._id
    if wait.manager? && wait.manager.length
      char = Characters.findOne {_id: wait.manager}
      resp["manager"] = 
        name: char.name
        avatar: "https://image.eveonline.com/Character/#{char._id}_128.jpg"
        id: char._id
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
  "hasComment": ->
    primary = _.findWhere @fits, {primary: true}
    return false if !primary?
    primary.comment? && primary.comment.length>0
  "getFitShiptype": ->
    primary = _.findWhere @fits, {primary: true}
    return "unknown" if !primary?
    typeids[primary.shipid+""]
  "pboost": ->
    wait = Waitlists.findOne()
    return [] if !wait?
    boost = wait.booster || []
    Characters.find {roles: "booster", active: true, _id: {$nin: boost}}
  "pmanager": ->
    wait = Waitlists.findOne()
    return [] if !wait?
    manage = [wait.commander]
    if wait.manager
      manage.push wait.manager
    Characters.find {roles: "manager", active: true, _id: {$nin: manage}}
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
  "click .openConvo": (e)->
    e.preventDefault()
    CCPEVE.startConversation @_id
  "click .delWaitlist": (e)->
    e.preventDefault()
    id = @_id
    char = Characters.findOne {_id: id}
    swal
      title: "Reject from Waitlist"
      text: "You are rejecting #{char.name} from the waitlist."
      type: "prompt"
      promptPlaceholder: "Rejection reason"
      promptDefaultValue: ""
    , (reason)->
      Meteor.call "deleteFromWaitlist", Session.get("hostHash"), id, false, reason, (err)->
        if err?
          $.pnotify
            title: "Can't Remove"
            text: err.reason
            type: "error"
        else
          CCPEVE.sendMail id, "Hello, TVP Pilot!", reason+rejectMail
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
        #CCPEVE.inviteToFleet id
        CCPEVE.showInfo 1377, id
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
  "click .viewComment": (e)->
    e.preventDefault()
    primary = _.findWhere @fits, {primary: true}
    return if !primary?
    swal
      title: "Comment"
      text: primary.comment
  "click .setCurrentSystem": ->
    Meteor.call "setCurrentSystem", Session.get("hostHash"), (err)->
      if err?
        $.pnotify
          title: "Can't Set System"
          text: err.reason
          type: "error"
