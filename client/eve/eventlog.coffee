Template.events.helpers
  "eventCount": ->
    EventLog.find().count()
  "events": ->
    EventLog.find({}, {sort: {time: -1}})
