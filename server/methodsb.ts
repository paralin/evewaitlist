import { Meteor } from 'meteor/meteor';
import { Characters } from '../schema/characters';
import { SolarSystems } from '../schema/solarsystem';
import { Settings } from '../schema/settings';
import { clientForUser } from './crest';

Meteor.methods({
  showOwnerDetails: function(id: number) {
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
    client.call('POST', 'characters/' + character._id + '/ui/openwindow/ownerdetails/', {
      data: {
        id: id,
      },
    });
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
});
