Meteor.startup =>
  return if CCPEVE?
  Meteor.setInterval ->
    perm = PNotify.desktop.checkPermission()
    Session.set "pnotifyPermission", perm
    Session.set "desktopPermission", perm is 0
  , 2000
  Tracker.autorun ->
    Meteor.subscribe "waitlists"
    id = Session.get("hostHash")
    return if !id?
    hand = Meteor.subscribe "ogbData", id
    if hand.ready() and !Characters.findOne({hostid: id})?
      Session.set "hostHash", null
      $.pnotify
        title: "Invalid ID"
        text: "There are no characters for that code, try again"
        type: "error"

Template.browserPage.events
  "click .toggleAlarmSound": (e)->
    e.preventDefault()
    sou = Session.get("alarmSoundEnabled") || false
    Session.set "alarmSoundEnabled", !sou
  "submit #session_code_form": (e)->
    e.preventDefault()
    id = $("#session_code").val()
    id = id.replace /\W/g, ''
    id = id.substr 0, Random.id().length
    $("#session_code").val id
    Meteor.call "validateHostHash", id, (err, res)->
      if err?
        $.pnotify
          title: "Invalid ID"
          text: "Copy the ID from the left side of the IGB page while in the waitlist EXACTLY."
          type: "error"
          delay: 3000
      else
        Session.set "hostHash", id
  "click .joinWaitlist": (e)->
    e.preventDefault()
    Meteor.call "joinWaitlist", Session.get("hostHash"), @_id, (err)->
      if err?
        $.pnotify
          title: "Can't Join Waitlist"
          text: err.reason
          type: "error"
  "click .leaveWaitlist": (e)->
    e.preventDefault()
    Meteor.call "leaveWaitlist", Session.get("hostHash"), @_id, (err)->
      if err?
        $.pnotify
          title: "Can't Leave Waitlist"
          text: err.reason
          type: "error"
  "click .enableDesktopNot": (e)->
    e.preventDefault()
    PNotify.desktop.permission()
Template.browserPage.helpers
  "desktopPermission": ->
    Session.get "desktopPermission"
  "sessionCode": ->
    Session.get "hostHash"
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
    char.waitlist? and char.waitlist is @_id
  "timeInWaitlist": ->
    time = Session.get "10sec"
    char = Session.get "me"
    moment(char.waitlistJoinedTime).fromNow true
  "alarmSoundEnabled": ->
    Session.get "alarmSoundEnabled"
