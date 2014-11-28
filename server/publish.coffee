Meteor.publishComposite "igbdata", (hostHash)->
  find: ->
    TrustStatus.find {_id: hostHash}, {limit: 1}
  children: [
    {
      find: (trust)->
        return if !(trust? and trust.status)
        Characters.find {hostid: hostHash}, {limit: 1, fields: {active: 0, lastActiveTime: 0}}
    }
  ]

Meteor.publishComposite "waitlists", ->
  find: ->
    Waitlists.find {}
  children: [
    {
      find: (waitlist)->
        return if !(waitlist? and waitlist.commander?)
        Characters.find {_id: waitlist.commander}, {limit: 1, fields: {name: 1}}
    }
  ]

Meteor.publish "fits", ->
  Fits.find()

Meteor.publish "eventlog", ->
  EventLog.find({})

Meteor.publish null, ->
  [Settings.find({}), Roles.find({})]

Meteor.publish "admin", (hostHash)->
  check hostHash, String
  char = Characters.findOne {hostid: hostHash}
  return [] unless char? and char.roles? and "admin" in char.roles
  Characters.find {}, {fields: {hostid: 0, lastActiveTime: 0}}
Meteor.publish "profile", (hostHash, charId)->
  check hostHash, String
  check charId, Number
  char = Characters.findOne {hostid: hostHash}
  return [] unless char? and char.roles? and "admin" in char.roles
  EventLog.find {charid: charId}
