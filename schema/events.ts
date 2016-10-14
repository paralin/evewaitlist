import { Mongo } from 'meteor/mongo';
// tslint:disable-next-line
export const EventLog = new Mongo.Collection<IEvent>('events');
this.EventLog = EventLog;

export interface IEvent {
  text: string;
  time: Date;
  charid: number;
};

export function recordEvent(charId: number, text: string) {
  EventLog.insert({
    text: text,
    time: new Date(),
    charid: charId,
  });
}
