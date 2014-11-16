Meteor.publishComposite "igbdata", (hostHash)->
  find: ->
    TrustStatus.find
      ident: hostHash
  children: [
      {
        find: (trust)->
          return if !(trust? and trust.status)
          Characters.find {hostid: hostHash}, {limit: 1, fields: {active: 0}}
      }
  ]

Meteor.publish "fits", ->
  Fits.find()
