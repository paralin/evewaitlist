showOwnerDetails = (id)->
  Meteor.call 'showOwnerDetails', id, (error) ->
    if error?
      swal
        title: 'Error'
        text: error.reason
        type: 'error'
Template.admin.helpers
  "incursion": ->
    Settings.findOne {_id: "incursion"}
  "corpInfo": ->
    info = ""
    if @corpname?
      info += "in <a class=\"showOwnerBtn\" href=\"\" owner-id=\"#{@corpid}\">#{@corpname}</a>"
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
  "click .showOwnerBtn": (e)->
    e.preventDefault()
    id = e.currentTarget.getAttribute('owner-id')
    if !id?
      return
    showOwnerDetails parseInt(id)
  "click .setCurrentSystem": ->
    Meteor.call "setCurrentSystem", (err)->
      if err?
        swal
          title: "Can't Set System"
          text: err.reason
          type: "error"
  "click .setCustomSystem": ->
    swal
      title: "Set Custom System"
      text: "Enter the system name exactly below."
      type: "prompt"
      promptPlaceholder: "Amarr"
      promptDefaultValue: ""
    , (value)=>
      return if !value? || value.length == 0
      Meteor.call "setCustomSystem", value, (err)->
        if err?
          swal
            title: "Invalid System"
            text: err.reason
            type: "error"
  "click .showshiptype": (e)->
    e.preventDefault()
    showOwnerDetails @shiptypeid
  "click .showsystem": (e)->
    e.preventDefault()
    showOwnerDetails @systemid
  "click .gotoprofile": (e)->
    e.preventDefault()
    Session.set "profilechar", @_id
    Session.set "igbpage", "profile"
  "click .closeWaitlist": (e)->
    e.preventDefault()
    Meteor.call "adminCloseWaitlist", (err)->
      if err?
        swal
          title: "Can't Close Waitlist"
          text: err.reason
          type: "error"
  "click #fcName": (e)->
    showOwnerDetails @fc.id
  "click #sysName": (e)->
    showOwnerDetails @sysid
