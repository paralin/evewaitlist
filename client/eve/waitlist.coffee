lswitcher = null
Template.waitlist.helpers
  "fleet": ->
    wait = Waitlists.findOne()
    return if !wait?
    commander = Characters.findOne({_id: wait.commander})
    {
      _id: wait._id
      counts: wait.stats
      fc:
        name: commander.name
        avatar: "https://image.eveonline.com/Character/#{commander._id}_128.jpg"
        id: commander._id
    }
  "shiptype": (id)->
    typeids[id]
  "avatar": (id)->
    "https://image.eveonline.com/Render/#{id}_128.png"
  "inwaitlist": ->
    char = Session.get "me"
    if !char?
      return false
    char.waitlist? and char.waitlist is @_id
  "timeInWaitlist": ->
    time = Session.get "10sec"
    char = Session.get "me"
    if !char? || !time?
      return "unknown"
    moment(char.waitlistJoinedTime).fromNow true

lastManualToggle = null
Template.logiSwitcher.onRendered ->
  selected = Session.get("me").logifive
  lswitcher = $("#logi-switcher").switcher
    theme: 'square'
    on_state_content: '<span>5</span>',
    selected: selected
    off_state_content: '<span>4</span>'
    on_toggle: (e)->
      lastManualToggle = e
      Meteor.call "setLogiLvl", e, (err)->
        if err?
          alert err

Template.logiSwitcher.onDestroyed ->
  lswitcher = null

###
Meteor.startup ->
  Tracker.autorun ->
    me = Session.get "me"
    return if !me? || !lswitcher? || lastManualToggle?
    if me.logifive
      lswitcher.on()
    else
      lswitcher.off()
###

Template.rolesInput.rendered = ->
  ele = $("#roles_input")
  ele.select2
    placeholder: "Fleet roles"
  ele.val(Session.get("me").fleetroles).trigger("change")
  ele.on "change", (e)->
    roles = ele.val()
    return if arraysEqual roles, Session.get("me").fleetroles
    Meteor.call "setRoles", roles, (err)->
      if err?
        swal
          title: "Can't Set Roles"
          text: err.reason
          type: "error"

Template.waitlist.events
  "click .makePrimary": (e)->
    e.preventDefault()
    Meteor.call "setPrimary", @fid, (err)->
      if err?
        swal
          title: "Can't Make Primary"
          text: err.reason
          type: "error"
  "click .joinWaitlist": (e)->
    e.preventDefault()
    user = Meteor.user()
    if !user?
      return doEveSignin()
    Meteor.call "joinWaitlist", @_id, (err)->
      if err?
        swal
          title: 'Can\'t Join Waitlist'
          text: err.reason
          type: "error"
  "click .leaveWaitlist": (e)->
    e.preventDefault()
    Meteor.call "leaveWaitlist", @_id, (err)->
      if err?
        swal
          title: "Can't Leave Waitlist"
          text: err.reason
          type: "error"
  "click #fcName": (e)->
    showOwnerDetails @fc.id
  "click .viewFit": (e)->
    e.preventDefault()
    showFitting @dna
  "click .removeFit": (e)->
    e.preventDefault()
    Meteor.call "delFit", @fid, (err, res)->
      if err?
        swal
          title: "Can't Delete Fit"
          text: err.reason
          type: "error"
        return
  "click .add-fit": (e)->
    e.preventDefault()
    field = $("#addFitInput")
    dna = filterDna field.val()
    field.val(dna)
    Meteor.call "addFit", dna, (err, res)->
      if err?
        swal
          title: "Invalid ShipDNA"
          text: err.reason
          type: "error"
        return
      $("#addFitInput").val("")
  "click .setComment": (e)->
    e.preventDefault()
    swal
      title: "Comment"
      text: "Enter a fit comment."
      input: "text"
      showCancelButton: true
      showLoaderOnConfirm: true
      confirmButtonText: 'Set Comment'
      preConfirm: (text)->
        swal.disableInput()
        return new Promise (resolve, reject)->
          Meteor.call "setComment", text, (er)->
            swal.enableInput()
            if er?
              reject(er.reason)
            else
              resolve()
