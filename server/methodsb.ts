import { Meteor } from 'meteor/meteor';
import { check } from 'meteor/check';
import { Characters } from '../schema/characters';
import { SolarSystems } from '../schema/solarsystem';
import { Settings } from '../schema/settings';
import { Waitlists, ISquad } from '../schema/waitlist';
import { clientForUser, CREST_ENDPOINT } from './crest';
import { openWaitlist } from './waitlist/manage';

import * as _ from 'underscore';
import * as winston from 'winston';

declare var logi: number[];
declare var dps: number[];
declare var updateCounts: any;

Meteor.methods({
  showOwnerDetails: function(id: any) {
    this.unblock();
    let character = Characters.findOne({
      uid: this.userId
    });
    if (character == null) {
      throw new Meteor.Error('error', 'Log in before doing this, please.');
    }
    let user = Meteor.users.findOne({_id: this.userId});
    if (user == null) {
      throw new Meteor.Error('error', 'Log in before doing this, please.');
    }
    let client = clientForUser(user);
    try {
      client.call('POST', 'characters/' + character._id + '/ui/openwindow/ownerdetails/', {
        data: {
          id: parseInt(id, 10),
        },
      });
    } catch (e) {
      throw new Meteor.Error('error', '' + e);
    }
  },
  sendEvemail: function(targetId: number, subject: string, message: string) {
    let character = Characters.findOne({
      uid: this.userId
    });
    if (character == null) {
      throw new Meteor.Error('error', 'Log in before doing this, please.');
    }
    let user = Meteor.users.findOne({_id: this.userId});
    if (user == null) {
      throw new Meteor.Error('error', 'Log in before doing this, please.');
    }
    let client = clientForUser(user);
    client.call('POST', 'characters/' + character._id + '/ui/openwindow/newmail/', {
      data: {
        body: message,
        recipients: [{id: targetId}],
        subject: subject,
      },
    });
  },
  setWaypoint: function(clearOthers: boolean, first: boolean, systemId: number) {
    this.unblock();
    let character = Characters.findOne({
      uid: this.userId
    });
    if (character == null) {
      throw new Meteor.Error('error', 'Log in before doing this, please.');
    }
    let user = Meteor.users.findOne({_id: this.userId});
    if (user == null) {
      throw new Meteor.Error('error', 'Log in before doing this, please.');
    }
    let client = clientForUser(user);
    client.call('POST', 'characters/' + character._id + '/ui/autopilot/waypoints/', {
      data: {
        clearOtherWaypoints: clearOthers,
        first: first,
        solarSystem: {id: systemId},
      },
    });
  },
  setCustomSystem: function(name) {
    name = name.trim().toLowerCase();
    let character = Characters.findOne({
      uid: this.userId
    });
    if (character == null) {
      throw new Meteor.Error('error', 'The server does not know about your character.');
    }
    if (!((character.roles != null) && character.roles.indexOf('admin') >= 0)) {
      throw new Meteor.Error('error', 'You are not authorized to perform this action.');
    }
    let user = Meteor.users.findOne({_id: this.userId});
    if (!user) {
      throw new Meteor.Error('error', 'The server does not know about your character.');
    }
    let fsys = SolarSystems.findOne({name_lower: name});
    if (!fsys) {
      throw new Meteor.Error('error', 'Cannot find the requested system.');
    }

    return Settings.update({
      _id: 'incursion'
    }, {
      $set: {
        sysid: parseInt(fsys._id, 10),
        sysname: fsys.name,
      }
    });
  },
  openWaitlist: function(fleeturl) {
    let chara = Characters.findOne({
      uid: this.userId,
    });
    if (!chara) {
      throw new Meteor.Error('error', 'The server does not know about your character.');
    }
    if (!((chara.roles != null) &&
          ((chara.roles.indexOf('command') >= 0) ||
           (chara.roles.indexOf('admin') >= 0)))) {
      throw new Meteor.Error('error', 'You are not an admin or a fleet commander.');
    }
    let waitlist = Waitlists.findOne({
      finished: false,
    });
    if (waitlist != null) {
      throw new Meteor.Error('error', 'There is already an active waitlist.');
    }
    return openWaitlist(chara, fleeturl);
  },
  deleteFromWaitlist: function(cid: string, accepted: boolean, reason: string) {
    check(accepted, Boolean);
    check(cid, String);
    if (!accepted) {
      check(reason, String);
    }
    let character = Characters.findOne({
      uid: this.userId
    });
    let user = Meteor.users.findOne({_id: this.userId});
    if (!character || !user) {
      throw new Meteor.Error('error', 'The server does not know about your character.');
    }
    if (!((character.roles != null) &&
          ((character.roles.indexOf('command') >= 0) ||
          (character.roles.indexOf('admin') >= 0) ||
          (character.roles.indexOf('manager') >= 0)))) {
      throw new Meteor.Error('error', 'You are not an admin or a fleet manager.');
    }
    let waitlist = Waitlists.findOne({
      finished: false,
      $or: [
        {
          commander: character._id
        }, {
          manager: character._id
        }
      ]
    });
    if (!waitlist) {
      throw new Meteor.Error('error', 'You are not a commander of the waitlist.');
    }
    let tchar = Characters.findOne({
      _id: cid,
      waitlist: waitlist._id
    });
    if (!tchar) {
      throw new Meteor.Error('error', 'Can\'t find that character.');
    }

    // Attempt to send invite ingame
    if (accepted) {
      let client = clientForUser(user);
      let inviteData: any = {
        character: {
          href: CREST_ENDPOINT + 'characters/' + cid + '/',
        },
        role: 'squadMember',
      };
      let squadInfo = waitlist.fleet_squads;
      let primaryFit = _.findWhere(tchar.fits, {primary: true});
      if (squadInfo && primaryFit) {
        let squad: ISquad;
        if (dps.indexOf(primaryFit.shipid) !== -1) {
          squad = squadInfo.dpsSquad;
        }
        if (logi.indexOf(primaryFit.shipid) !== -1) {
          squad = squadInfo.logiSquad;
        }
        if (squad) {
          inviteData['squadID'] = squad.id;
          inviteData['wingID'] = squad.wing_id;
        }
      }
      try {
        winston.info('Inviting ' + tchar.name + ' to fleet.');
        client.call('POST', waitlist.fleeturl + 'members/', {
          data: inviteData,
        });
      } catch (e) {
        console.log(e);
        if (e.response && e.response.content) {
          let edetails = JSON.parse(e.response.content)['message'];
          if (edetails) {
            throw new Meteor.Error('error', '' + edetails);
          }
        }
        throw new Meteor.Error('error', '' + e);
      }
    }

    Characters.update({
      _id: cid
    }, {
      $set: {
        waitlist: null,
        waitlistJoinedTime: null
      }
    });
    updateCounts(waitlist._id);
  },
});
