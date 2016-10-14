import { Mongo } from 'meteor/mongo';

// tslint:disable-next-line
export const Roles = new Mongo.Collection('roles');

export interface IRole {
  description: string;
  name: string;
  'protected': boolean;
};
this.Roles = Roles;
