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
  "character": ->
    Characters.findOne({hostid: Session.get("hostHash")})
  "inwaitlist": ->
    char = Characters.findOne({hostid: Session.get("hostHash")})
    char.waitlist? and char.waitlist is @_id

Template.waitlist.events
  "click .joinWaitlist": (e)->
    e.preventDefault()
    Meteor.call "joinWaitlist", Session.get("hostHash"), @_id, (err)->
      $.pnotify
        title: "Can't Join Waitlist"
        text: err.reason
        type: "error"
  "click .leaveWaitlist": (e)->
    e.preventDefault()
    Meteor.call "leaveWaitlist", Session.get("hostHash"), @_id, (err)->
      $.pnotify
        title: "Can't Leave Waitlist"
        text: err.reason
        type: "error"
  "click #fcName": (e)->
    CCPEVE.showInfo 1377, @fc.id
  "click .viewFit": (e)->
    e.preventDefault()
    CCPEVE.showFitting @dna
  "click .removeFit": (e)->
    e.preventDefault()
    Meteor.call "delFit", Session.get("hostHash"), @fid, (err, res)->
      if err?
        $.pnotify
          title: "Can't Delete Fit"
          text: err.reason
          type: "error"
        return
  "click .add-fit": (e)->
    e.preventDefault()
    field = $("#addFitInput")
    dna = filterDna field.val()
    field.val(dna)
    Meteor.call "addFit", Session.get("hostHash"), dna, (err, res)->
      if err?
        $.pnotify
          title: "Invalid ShipDNA"
          text: err.reason
          type: "error"
        return
      $("#addFitInput").val("")
