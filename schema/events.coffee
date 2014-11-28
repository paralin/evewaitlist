@EventLog = new Mongo.Collection "events"

EventSchema = new SimpleSchema
  text:
    type: String
    label: "The text for the event"
  time:
    type: Date
    label: "The time of the event"
  charid:
    type: Number
    label: "The character ID"
    index: true

EventLog.attachSchema EventSchema
