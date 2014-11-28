@Roles = new Mongo.Collection "roles"

RolesSchema = new SimpleSchema
  description:
    type: String
  name:
    type: String
  protected:
    type: Boolean
    optional: true

Roles.attachSchema RolesSchema
