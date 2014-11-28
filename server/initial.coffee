if Settings.find().count() < 1
  Settings.remove {} 
  Settings.insert
    _id: "incursion"
    sysid: 30005322
    sysname: "Scolluzer"
if Roles.find().count() < 5
  Roles.remove {}
  Roles.insert
    _id: "admin"
    description: "Access to control panel."
    name: "Administrator"
    protected: true
  Roles.insert
    _id: "events"
    description: "Access to event log."
    name: "Event Log"
  Roles.insert
    _id: "command"
    description: "Fleet commander, can start waitlist, add boosters and managers."
    name: "Fleet Commander"
  Roles.insert
    _id: "booster"
    description: "Can be added as a booster to a fleet."
    name: "Booster"
  Roles.insert
    _id: "manager"
    description: "Can be added as a fleet manager to invite and decline members."
    name: "Booster"
