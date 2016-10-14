import { Meteor } from 'meteor/meteor';
import { Waitlists, IWaitlist } from '../../schema/waitlist';
import { ICharacter } from '../../schema/characters';
import { clientForUser, CREST_ENDPOINT, ICrestTree } from '../crest/client';

// tslint:disable-next-line
export const fleetUrlRegex = /^(https:\/\/)(crest)(-[a-z]+)?(\.eveonline\.com)(\/fleets\/)([0-9]+)(\/)$/;

export function openWaitlist(character: ICharacter, fleetUrl: string) {
  if (!character) {
    return;
  }
  let user = Meteor.users.findOne({_id: character.uid});
  if (!user) {
    return;
  }
  let client = clientForUser(user);
  fleetUrl = fleetUrl.trim();
  let match = fleetUrl.match(fleetUrlRegex);
  if (fleetUrl.indexOf(CREST_ENDPOINT) !== 0 || !match) {
    throw new Meteor.Error('error', 'That does not look like a valid fleet URL.');
  }
  // attempt to fetch that fleet
  let members: ICrestTree[];
  try {
    let ct = client.callTree('GET', fleetUrl, {});
    // fleet is valid, check members
    members = ct['members'];
  } catch (e) {
    throw new Meteor.Error('error', 'Unable to verify that fleet, please check the URL.');
  }
  /*
  let fcFound = false;
  let fcId = parseInt(character._id, 10);
  for (let member of members) {
    if (member['character']['id'] === fcId) {
      fcFound = true;
      break;
    }
  }
  if (!fcFound) {
    throw new Meteor.Error('error', 'You are not a member of that fleet.');
  }*/

  if (Waitlists.findOne({finished: false})) {
    throw new Meteor.Error('error', 'Someone else opened the waitlist already.');
  }

  Waitlists.insert(<IWaitlist>{
    commander: character._id,
    fleeturl: fleetUrl,
    finished: false,
    stats: {
      logi: 0,
      other: 0,
      dps: 0
    },
    used: false,
    manager: null,
    booster: null,
  });
}
/*
@openWaitlist = (char)->
  return if !char?
  Waitlists.insert
    commander: char._id
    finished: false
    stats:
      logi: 0
      other: 0
      dps: 0
    used: false
    manager: null
    booster: null
    */
