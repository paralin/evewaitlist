if Settings.find().count() is 0
  Settings.insert
    _id: "incursion"
    sysid: 30005322
    sysname: "Scolluzer"
if Roles.find().count() is 0
  Roles.insert
    _id: "admin"
    description: "Access to control panel."
    name: "Administrator"
    protected: true
  Roles.insert
    _id: "events"
    description: "Access to event log."
    name: "Event Log"
