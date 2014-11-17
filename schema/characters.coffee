@Characters = new Mongo.Collection "characters"
###
CharacterSchema = new SimpleSchema
    charId:
        type: String
        index: true
    name:
        type: String
    system:
        type: String
    systemid:
        type: Number
    stationname:
        type: String
        optional: true
    stationid:
        type: Number
        optional: true
    corpname:
        type: String
        optional: true
    corpid:
        type: Number
        optional: true
    corproles:
        type: Number
        optional: true
    alliancename:
        type: String
        optional: true
    allianceid:
        type: Number
        optional: true
    shipname:
        type: String
        optional: true
    shipid:
        type: Number
        optional: true
    shiptype:
        optional: true
        type: String
    shiptypeid:
        type: Number
        optional: true
    hostid:
        type: String
        index: true
    active:
        type: Boolean
        index: true
    lastActiveTime:
        type: Number
    roles:
      type: [String]
      optional: true
    fits:
      type: [Object]
      optional: true
###
#Characters.attachSchema CharacterSchema
