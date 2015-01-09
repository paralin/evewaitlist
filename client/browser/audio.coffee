Meteor.startup =>
  return if CCPEVE?
  window.alertSound = new buzz.sound "/audio/alarm.ogg"
