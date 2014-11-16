@Fits = new Mongo.Collection "fits"

FitsSchema = new SimpleSchema
  label:
    type: String
    label: "The label of the fit"
  description:
    type: String
    label: "The description of the fit"
  page:
    type: String
    label: "The page to display on, for example, logifits"
  shiplabel:
    type: String
    label: "The full label of the ship, example Scimitar"
  shipid:
    type: Number
    label: "The ship type id"
  shipdna:
    type: String
    label: "The ship DNA string"

Fits.attachSchema FitsSchema
