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
    Waitlists.find {finished: false}, {limit: 1}
  children: [
    {
      find: (waitlist)->
        return if !(waitlist? and waitlist.commander?)
        Characters.find {_id: waitlist.commander}, {limit: 1, fields: {name: 1}}
    }
  ]

Meteor.publishComposite "command", (hash)->
  find: ->
    char = Characters.findOne {hostid: hash}
    return [] if !char? or !(char.roles)? or !(("admin" in char.roles) or ("manager" in char.roles) or ("command" in char.roles))
    Waitlists.find {$or: [{commander: char._id}, {manager: char._id}], finished: false}, {limit: 1}
  children: [
    {
      find: (waitlist)->
        return if !waitlist?
        Characters.find {waitlist: waitlist._id}, {fields: {name: 1, fits: 1, shiptype: 1, stationid: 1, systemid: 1, system: 1, waitlist: 1, stationname: 1, regionname: 1, alliancename: 1, roles: 1}}
    },
    {
      find: (waitlist)->
        return if !(waitlist? and waitlist.booster?)
        Characters.find {_id: waitlist.booster}, {limit: 1, fields: {name: 1}}
    },
    {
      find: (waitlist)->
        Characters.find {$or: [{roles: "booster"}, {roles: "manager"}], active: true}, {fields: {name: 1, roles: 1, active: 1, waitlist: 1}}
    },
    {
      find: (waitlist)->
        return if !(waitlist? and waitlist.manager?)
        Characters.find {_id: waitlist.manager}, {limit: 1, fields: {name: 1}}
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
  Characters.find {}, {fields: {shiptype: 1, system: 1, systemid: 1, corpname: 1, alliancename: 1, banned: 1, roles: 1, shipname: 1, regionname: 1, name: 1, corpid: 1, allianceid: 1, shiptypeid: 1, stationname: 1, stationid: 1, fits: 1}}

Meteor.publish "profile", (hostHash, charId)->
  check hostHash, String
  check charId, Number
  char = Characters.findOne {hostid: hostHash}
  return [] unless char? and char.roles? and "admin" in char.roles
  EventLog.find {charid: charId}
