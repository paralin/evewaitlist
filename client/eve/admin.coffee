Template.admin.helpers
  "incursion": ->
    Settings.findOne {_id: "incursion"}
  "characters": ->
    Characters.find({})
  "corpInfo": ->
    info = ""
    if @corpid?
      info += "in <a href=\"javascript:CCPEVE.showInfo(2, #{@corpid})\">#{@corpname}</a>"
    if @allianceid?
      info += "<br/>of <a href=\"javascript:CCPEVE.showInfo(16159, #{@allianceid})\">#{@alliancename}</a>"
    info

Template.admin.events
  "click .setCurrentSystem": ->
    Meteor.call "setCurrentSystem", Session.get("hostHash"), (err)->
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
