import { IService } from '../service';
import { Meteor } from 'meteor/meteor';
import { clientForUser } from '../crest';
import { Characters, ICharacter } from '../../schema/characters';
import { recordEvent } from '../../schema/events';

declare var Presences: any;

import * as winston from 'winston';
import * as _ from 'underscore';

export class CharacterFetcher {
  // Fetches initial character info from CREST
  public fetchForUser(user: Meteor.User, firstTime: boolean = false) {
    let client = clientForUser(user);
    try {
      let charId: number = user.profile.eveOnlineCharacterId;
      let _id = charId + '';
      let oldCharacter: ICharacter = Characters.findOne({_id: _id});
      let res = client.callTree('GET', 'characters/' + user.profile.eveOnlineCharacterId + '/', {});
      let character: ICharacter = {
        active: false,
        lastActiveTime: ((oldCharacter || {lastActiveTime: null}).lastActiveTime) || new Date(),
        uid: user._id,
        name: res['name'],
        banned: (oldCharacter || {banned: false}).banned || false,
        corpname: res['corporation']['name'],
        corpid: res['corporation']['id'],
      };

      // check ship

      // check location
      let loc = res['location'];
      character.active = loc && Object.keys(loc).length > 0;

      if (character.active) {
        character.lastActiveTime = new Date();
        let solarSys = loc['solarSystem'];
        character.system = solarSys['name'];
        character.systemid = solarSys['id'];

        let station = loc['station'];
        if (station) {
          character.stationid = station['id'];
          character.stationname = station['name'];
        } else {
          character.stationid = null;
          character.stationname = null;
        }
      }

      Characters.upsert({_id: _id}, {$set: character});
      if (!oldCharacter) {
        recordEvent(charId, character.name + ' signed in for the first time.');
      }
      if (firstTime) {
        Meteor.users.update({_id: character.uid}, {$set: {'profile.characterCreated': true}});
      }
      if (!oldCharacter) {
        return;
      }

      // calculate update
      for (let k in character) {
        if (!character.hasOwnProperty(k)) {
          continue;
        }

        let v: any = character[k];
        let ov: any = oldCharacter[k];
        if (ov !== v) {
          if (!(k === 'hostid' || k === 'lastActiveTime' || k === 'active')) {
            winston.debug(character.name + ': ' + k + ' - ' + ov + ' -> ' + v);
          }
          let text: string = null;
          if (k === 'system') {
            text = character.name + ' jumped from ' + ov + ' to ' + v + '.';
          } else if (k === 'stationname') {
            if (v != null) {
              text = character.name + ' docked at ' + v + '.';
            } else {
              text = character.name + ' undocked from ' + ov;
            }
          } else if (k === 'corpname') {
            if (v != null) {
              text = character.name + ' joined corp ' + v + '.';
            } else {
              text = character.name + ' dropped corp ' + ov;
            }
          } else if (k === 'corproles') {
            text = character.name + ' corp roles changed to ' + v;
          } else if (k === 'shipname') {
            text = character.name + ' changed ship name to ' + v;
          } else if (k === 'shiptype') {
            text = character.name + ' reshipped to ' + v + ' from ' + ov;
          }
          if (text) {
            recordEvent(charId, text);
          }
        }
      }
    } catch (e) {
      winston.error('Unable to fetch character info: ' + e);
    }
  }
}

export let characterFetcher = new CharacterFetcher();

export class CharacterFetcherService implements IService {
  private running = false;
  private updateTimeout: number;

  public init() {
    let users = Meteor.users.find(
      {'profile.eveOnlineCharacterId': {$exists: true},
        'profile.characterCreated': {$exists: false}}).fetch();
    for (let user of users) {
      characterFetcher.fetchForUser(user, true);
    }
  }

  public startup() {
    this.running = true;
    this.setCheckTimeout();
  }

  public close() {
    this.running = false;
    Meteor.clearTimeout(this.updateTimeout);
  }

  private performUpdate() {
    // build list of user ids to check
    // grab list of people viewing app
    let onlineUsers = Presences.find({
      state: 'online',
      userId: {$exists: true},
    }).fetch().map((p) => { return p.userId; });
    let activeUsers = Characters.find({
      active: true,
    }).fetch().map((c) => { return c.uid; });

    let toCheck: string[] = _.uniq(onlineUsers.concat(activeUsers)) as string[];

    for (let uid of toCheck) {
      let user = Meteor.users.findOne({_id: uid});
      if (!user) {
        Characters.remove({uid: uid});
        continue;
      }

      characterFetcher.fetchForUser(user);
    }

    this.setCheckTimeout();
  }

  private setCheckTimeout() {
    this.updateTimeout = Meteor.setTimeout(() => {
      this.performUpdate();
    }, 5000);
  }
}
