import { Meteor } from 'meteor/meteor';
import { Mongo } from 'meteor/mongo';

// tslint:disable-next-line
export const Waitlists = new Mongo.Collection<IWaitlist>('waitlist');
this.Waitlists = Waitlists;

if (Meteor.isServer) {
  Waitlists._ensureIndex({finished: 1});
}

export interface IStats {
  logi: number;
  dps: number;
  other: number;
}

export interface IWaitlist {
  commander: string;
  stats: IStats;
  finished: boolean;
  used: boolean;
  booster?: string;
  manager?: string;
};
