import { Mongo } from 'meteor/mongo';

export interface ISolarSystem {
  _id: string;
  name: string;
  name_lower: string;
  lastFetch?: Date;
}
// tslint:disable-next-line
export let SolarSystems = new Mongo.Collection<ISolarSystem>('solarSystems');
this.SolarSystems = SolarSystems;
