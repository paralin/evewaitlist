Template.registerHelper "character", ->
  Session.get "me"
Template.registerHelper "characters", ->
  Characters.find {}
Template.registerHelper "inStagingSystem", ->
  char = Session.get "me"
  char.systemid is Settings.findOne({_id: "incursion"}).sysid
Template.registerHelper "stagingSystem", ->
  Settings.findOne {_id: "incursion"}
