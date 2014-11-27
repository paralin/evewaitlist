@TrustStatus = new Meteor.Collection "truststat"

TrustSchema = new SimpleSchema
  _id:
    type: String
  status:
    type: Boolean

TrustStatus.attachSchema TrustSchema
