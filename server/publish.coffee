Meteor.publishComposite "igbdata", (hostHash)->
  find: ->
    TrustStatus.find {_id: hostHash}, {limit: 1}
  children: [
    {
      find: (trust)->
        return if !(trust? and trust.status)
        Characters.find {hostid: hostHash}, {limit: 1, fields: {active: 0}}
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
