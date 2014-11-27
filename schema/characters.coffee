@Characters = new Mongo.Collection "characters"
FitSchema = new SimpleSchema
  dna:
    type: String
  shipid:
    type: Number
  fid:
    type: String
  primary:
    type: Boolean
CharacterSchema = new SimpleSchema
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
  alliancename:
    type: String
    optional: true
  allianceid:
    type: Number
    optional: true
  shipname:
    type: String
  shipid:
    type: Number
  shiptype:
    type: String
  shiptypeid:
    type: Number
  corproles:
    type: String
    optional: true
  waitlist:
    type: String
    optional: true
  hostid:
    type: String
    index: true
  active:
    type: Boolean
  lastActiveTime:
    type: Number
  roles:
    type: [String]
    optional: true
  fits:
    type: [FitSchema]
    optional: true

Characters.attachSchema CharacterSchema
