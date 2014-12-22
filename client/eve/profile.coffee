Template.profile.helpers
  "character": ->
    Characters.findOne {_id: Session.get("profilechar")}
  "banDisabled": ->
    @roles? and "admin" in @roles
  "noRoles": ->
    !(@roles? and @roles.length>0)
  "avatar": (id)->
    "https://image.eveonline.com/Render/#{id}_128.png"
  "shiptype": (id)->
    typeids[id]
  "events": ->
    EventLog.find {charid: parseInt Session.get("profilechar")}, {sort: {time: -1}}
  "allroles": ->
    Roles.find {}
  "hasRole": ->
    char = Characters.findOne {_id: Session.get("profilechar")}
    return false if !char? or !char.roles?
    @_id in char.roles
  "props": ->
    char = Characters.findOne {_id: Session.get("profilechar")}
    desc = []
    return desc if !char?
    for k, v of CharactersDesc
      val = {n: v}
      if char[k]?
        val.v = char[k]
      else
        val.v = "None"
      desc.push val
    desc

Template.profile.events
  "click .viewFit": (e)->
    e.preventDefault()
    CCPEVE.showFitting @dna
  "click .addRole": (e)->
    e.preventDefault()
    Meteor.call "addRole", Session.get("hostHash"), $(e.currentTarget).attr("cid"), @_id, (err)->
      if err?
        $.pnotify
          title: "Can't Add Role"
          text: err.reason
          type: "error"
  "click .removeRole": (e)->
    e.preventDefault()
    Meteor.call "removeRole", Session.get("hostHash"), $(e.currentTarget).attr("cid"), @_id, (err)->
      if err?
        $.pnotify
          title: "Can't Remove Role"
          text: err.reason
          type: "error"
  "click .banCharacter": (e)->
    e.preventDefault()
    Meteor.call "banCharacter", Session.get("hostHash"), @_id, (err)->
      if err?
        $.pnotify
          title: "Can't Ban Character"
          text: err.reason
          type: "error"
  "click .unbanCharacter": (e)->
    e.preventDefault()
    Meteor.call "unbanCharacter", Session.get("hostHash"), @_id, (err)->
      if err?
        $.pnotify
          title: "Can't Unban Character"
          text: err.reason
          type: "error"
