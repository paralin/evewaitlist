import { Meteor } from 'meteor/meteor';
import { Mongo } from 'meteor/mongo';

// tslint:disable-next-line
export let Characters = new Mongo.Collection<ICharacter>('characters');
this.Characters = Characters;

if (Meteor.isServer) {
  Characters._ensureIndex({uid: 1, waitlist: 1, active: 1});
}

export interface IFit {
  dna: string;
  shipid: number;
  fid: string;
  primary: boolean;
  comment?: string;
}

export interface ICharacter {
  _id?: string;
  uid: string;
  name: string;
  banned: boolean;
  system?: string;
  systemid?: number;
  stationname?: string;
  stationid?: number;
  corpname: string;
  corpid: number;
  shipname?: string;
  shipid?: string;
  shiptype?: string;
  shiptypeid?: number;
  waitlist?: string;
  waitlistJoinedTime?: number;
  waitlistPosition?: number;
  active: boolean;
  lastActiveTime: Date;
  roles?: string[];
  fits?: IFit[];
  regionname?: string;
  regionid?: number;
  logifive?: boolean;
  fleetroles?: string[];
}

this.CharactersDesc = {
  name: 'Name',
  shipname: 'Ship Name',
  shiptype: 'Ship',
  corpname: 'Corporation',
  corproles: 'Roles',
  stationname: 'Station',
  system: 'System',
  regionname: 'Region'
};

(Characters as any).initEasySearch(['name'], {
  'limit': 20
});
