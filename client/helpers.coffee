getMyCharacter = ->
  user = Meteor.user()
  if !user?
    return null
  Characters.findOne {uid: user._id}
Template.registerHelper "character", ->
  getMyCharacter()

Template.registerHelper "inStagingSystem", ->
  char = getMyCharacter()
  if !char?
    return false
  char.systemid is Settings.findOne({_id: "incursion"}).sysid

Template.registerHelper "stagingSystem", ->
  Settings.findOne {_id: "incursion"}
