Template.command.helpers
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
  "isCommander": ->
    wait = Waitlists.findOne()
    return false if !wait?
    wait.commander is (Session.get("me"))._id
  "nisCommander": ->
    wait = Waitlists.findOne()
    return true if !wait?
    wait.commander isnt (Session.get("me"))._id
Template.command.events
  "click #fcName": (e)->
    CCPEVE.showInfo 1377, @fc.id
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
