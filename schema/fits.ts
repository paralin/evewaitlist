import { Mongo } from 'meteor/mongo';

// tslint:disable-next-line
export const Fits = new Mongo.Collection('fits');
this.Fits = Fits;

export interface IFit {
  label: string;
  description: string;
  page: string;
  shiplabel: string;
  shipid: number;
  shipdna: string;
};
