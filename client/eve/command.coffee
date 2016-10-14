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
    wait.commander is (Session.get("me") || {})._id
  "nisCommander": ->
    wait = Waitlists.findOne()
    return true if !wait?
    wait.commander isnt (Session.get("me") || {})._id
  "isCommanderOrManager": ->
    wait = Waitlists.findOne()
    return false if !wait?
    meid = (Session.get("me") || {})._id
    wait.commander is meid or wait.manager is meid
  "canBecomeFC": ->
    wait = Waitlists.findOne()
    return false if !wait?
    me = Session.get "me"
    if !me?
      return false
    meid = me._id
    wait.commander isnt meid and !(wait.booster? and meid in wait.booster) and me.roles? and "command" in me.roles
  "char": (i)->
    search = null
    search = logi if i is 0
    search = dps if i is 1
    sort = {waitlistJoinedTime: 1}
    waitlist = Waitlists.findOne()
    if !waitlist?
      return null
    if search?
      return Characters.find {"fits": {$elemMatch: {primary: true, shipid: {$in: search}}}, "waitlist": waitlist._id}, {sort: sort}
    else
      return Characters.find {"fits": {$elemMatch: {primary: true, shipid: {$not: {$in: _.union(logi, dps)}}}}, "waitlist": waitlist._id}, {sort: sort}
  "hasComment": ->
    primary = _.findWhere @fits, {primary: true}
    return false if !primary?
    primary.comment? && primary.comment.length>0
  "tooltipAttrs": ->
    rstr = "No roles."
    if @fleetroles? and @fleetroles.length > 0
      rstr = "Roles: #{@fleetroles.join()}"
    return {
      "data-tooltip": "Logi #{if @logifive then 5 else 4} - #{rstr}"
    }
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
    showOwnerDetails @fc.id
  "click #boosterName": (e)->
    if @booster?
      showOwnerDetails @booster.id
  "click #managerName": (e)->
    if @manager?
      showOwnerDetails @manager.id
  "click .closeWaitlist": (e)->
    Meteor.call "closeWaitlist", (err)->
      if err?
        swal
          title: "Can't Close Waitlist"
          text: err.reason
          type: "error"
  "click .openWaitlist": (e)->
    inp = swal
      title: "Fleet URL"
      text: "Click the dropdown at the top left of the fleet window, and click 'Copy Fleet URL', then paste it here."
      input: "text"
      showCancelButton: true
      showLoaderOnConfirm: true
      confirmButtonText: 'Open'
      preConfirm: (fleetUrl)->
        swal.disableInput()
        return new Promise (resolve, reject)->
          Meteor.call "openWaitlist", fleetUrl, (er)->
            swal.enableInput()
            if er?
              reject(er.reason)
            else
              resolve()
  "click .follower-name": (e)->
    e.preventDefault()
    showOwnerDetails @_id
  "click .follower-username": (e)->
    e.preventDefault()
    primary = _.findWhere @fits, {primary: true}
    return if !primary?
    showFitting primary.dna
  "click .openConvo": (e)->
    e.preventDefault()
    showOwnerDetails @_id
  "click .delWaitlist": (e)->
    e.preventDefault()
    id = @_id
    char = Characters.findOne {_id: id}
    swal
      title: "Reject from Waitlist"
      text: "You are rejecting #{char.name} from the waitlist."
      inputPlaceholder: "Rejection reason"
      confirmButtonColor: "#DD6B55"
      confirmButtonText: "Reject"
      input: "text"
      showLoaderOnConfirm: true
      preConfirm: (reason)->
        swal.disableInput()
        return new Promise (resolve, reject)->
          Meteor.call "deleteFromWaitlist", id, false, reason, (er)->
            swal.enableInput()
            if er?
              reject(er.reason)
            else
              if reason? and reason.length
                sendEvemail id, 'Hello, Incursion Pilot!', reason+rejectMail
              swal.close()
              resolve()
  "click .sendInv": (e)->
    e.preventDefault()
    id = @_id
    inp = swal
      title: 'Inviting...'
      text: 'Attempting to invite ' + @name + '...'
      showConfirmButton: false
      showCancelButton: false
      allowOutsideClick: false
    swal.showLoading()
    showOwnerDetails id
    Meteor.call "deleteFromWaitlist", id, true, (err)->
      swal.hideLoading()
      swal.close()
      if err?
        swal
          title: "Can't Accept"
          text: err.reason
          type: "error"
  "click .setBoost": (e)->
    e.preventDefault()
    id = @_id
    Meteor.call "setBooster", id, (err)->
      if err?
        swal
          title: "Can't Set Booster"
          text: err.reason
          type: "error"
  "click .removeBoost": (e)->
    e.preventDefault()
    id = @_id
    Meteor.call "removeBooster", (err)->
      if err?
        swal
          title: "Can't Remove Booster"
          text: e.reason
          type: "error"
  "click .setManager": (e)->
    e.preventDefault()
    id = @_id
    Meteor.call "setManager", id, (err)->
      if err?
        swal
          title: "Can't Set Manager"
          text: err.reason
          type: "error"
  "click .removeManager": (e)->
    e.preventDefault()
    id = @_id
    Meteor.call "removeManager", (err)->
      if err?
        swal
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
    Meteor.call "setCurrentSystem", (err)->
      if err?
        swal
          title: "Can't Set System"
          text: err.reason
          type: "error"
  "click .becomeFC": ->
    Meteor.call "becomeFC", Waitlists.findOne()._id, (err)->
      if err?
        swal
          title: "Can't Become FC"
          text: err.reason
          type: "error"
