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
  comment:
    type: String
    optional: true
CharacterSchema = new SimpleSchema
  name:
    type: String
  system:
    type: String
  banned:
    type: Boolean
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
  regionname:
    type: String
  regionid:
    type: Number

@CharactersDesc =
  name: "Name"
  shipname: "Ship Name"
  shiptype: "Ship"
  corpname: "Corporation"
  corproles: "Roles"
  alliancename: "Alliance"
  stationname: "Station"
  system: "System"
  regionname: "Region"

Characters.attachSchema CharacterSchema
