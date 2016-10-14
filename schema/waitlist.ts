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

export interface ISquad {
  id: number;
  wing_id: number;
}

export interface ISquadInfo {
  logiSquad?: ISquad;
  dpsSquad?: ISquad;
  otherSquad?: ISquad;
}

export interface IWaitlist {
  _id?: string;
  fleeturl: string;
  commander: string;
  stats: IStats;
  fleet_stats?: IStats;
  fleet_squads?: ISquadInfo;
  finished: boolean;
  used: boolean;
  booster?: string;
  manager?: string;
};
