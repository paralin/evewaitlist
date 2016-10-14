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

export interface IFleetMember {
  id: number;
  name: string;
  shipid: number;
  shipname: string;
}

export interface IFleetMembers {
  logi: IFleetMember[];
  dps: IFleetMember[];
  other: IFleetMember[];
}

export interface IWaitlist {
  _id?: string;
  fleeturl: string;
  commander: string;
  stats: IStats;
  fleet_squads?: ISquadInfo;
  fleet_members?: IFleetMembers;
  finished: boolean;
  used: boolean;
  booster?: string;
  manager?: string;
};
