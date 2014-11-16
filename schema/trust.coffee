@TrustStatus = new Meteor.Collection "truststat"

TrustSchema = new SimpleSchema
    ident:
        type: String
        index: true
    status:
        type: Boolean

TrustStatus.attachSchema TrustSchema
