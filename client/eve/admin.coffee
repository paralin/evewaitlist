Template.admin.helpers
  "incursion": ->
    Settings.findOne {_id: "incursion"}
  "corpInfo": ->
    info = ""
    if @corpname?
      info += "in <a href=\"javascript:CCPEVE.showInfo(2, #{@corpid})\">#{@corpname}</a>"
    if @alliancename?
      info += "<br/>of <a href=\"javascript:CCPEVE.showInfo(16159, #{@allianceid})\">#{@alliancename}</a>"
    info
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
  "characters": ->
    Characters.find {}, {sort: {active: -1, name: 1}}

Template.admin.events
  "click .setCurrentSystem": ->
    Meteor.call "setCurrentSystem", Session.get("hostHash"), (err)->
      if err?
        $.pnotify
          title: "Can't Set System"
          text: err.reason
          type: "error"
  "click .setCustomSystem": ->
    swal
      title: "Set Custom System"
      text: "Drag the system name to a chat message, send the message, right click it and select copy, and paste it in this field."
      type: "prompt"
      promptPlaceholder: "<url=showinfo:5//30004852>System</url>"
      promptDefaultValue: ""
    , (value)=>
      return if !value? || value.length == 0
      matches = filterSys value
      if matches.length == 0
        swal
          title: "Invalid System"
          text: "Couldn't find a valid system in the input you pasted. Be sure to follow the instructions closely!"
          type: "error"
      else
        Meteor.call "setCustomSystem", Session.get("hostHash"), matches[0], (err)->
          if err?
            $.pnotify
              title: "Can't Set System"
              text: err.reason
              type: "error"
  "click .showshiptype": (e)->
    e.preventDefault()
    CCPEVE.showInfo @shiptypeid
  "click .showsystem": (e)->
    e.preventDefault()
    CCPEVE.showInfo 5, @systemid
  "click .gotoprofile": (e)->
    e.preventDefault()
    Session.set "profilechar", @_id
    Session.set "igbpage", "profile"
  "click .closeWaitlist": (e)->
    e.preventDefault()
    Meteor.call "adminCloseWaitlist", Session.get("hostHash"), (err)->
      if err?
        $.pnotify
          title: "Can't Close Waitlist"
          text: err.reason
          type: "error"
  "click #fcName": (e)->
    CCPEVE.showInfo 1377, @fc.id
  "click #sysName": (e)->
    CCPEVE.showInfo 5, @sysid
