Session.set "10sec", new Date()
Meteor.setInterval ->
  Session.set "10sec", new Date()
, 10000
