import { Meteor } from 'meteor/meteor';
import { Characters, ICharacter } from '../schema/characters';
import { Waitlists } from '../schema/waitlist';
import { EventLog } from '../schema/events';
import { Fits } from '../schema/fits';
import { Settings } from '../schema/settings';
import { Roles } from '../schema/roles';

Meteor.publish('igbdata', function() {
  return Characters.find({
    uid: this.userId,
  }, {
    limit: 1,
    fields: {
      active: 0,
      lastActiveTime: 0,
      regionname: 0,
      regionid: 0,
    }
  });
});

(Meteor as any).publishComposite('waitlists', function() {
  return {
    find: function() {
      return Waitlists.find({
        finished: false
      }, {
        limit: 1
      });
    },
    children: [
      {
        find: function(waitlist) {
          if (!((waitlist != null) && (waitlist.commander != null))) {
            return;
          }
          return Characters.find({
            _id: waitlist.commander
          }, {
            limit: 1,
            fields: {
              name: 1
            }
          });
        }
      }
    ]
  };
});

(Meteor as any).publishComposite('command', function() {
  return {
    find: function(): any {
      let uid = this.userId;
      if (!uid) {
        return [];
      }
      let chara = Characters.findOne({
        uid: uid,
      });
      if ((chara == null) ||
          (chara.roles == null) ||
          !((chara.roles.indexOf('admin')) >= 0) ||
          (chara.roles.indexOf('manager') >= 0) ||
          (chara.roles.indexOf('command') >= 0)) {
        return [];
      }
      return Waitlists.find({
        finished: false
      }, {
        limit: 1
      });
    },
    children: [
      {
        find: function(waitlist) {
          if (waitlist == null) {
            return;
          }
          return Characters.find({
            waitlist: waitlist._id
          }, {
            fields: {
              name: 1,
              fits: 1,
              shiptype: 1,
              stationid: 1,
              systemid: 1,
              system: 1,
              waitlist: 1,
              waitlistJoinedTime: 1,
              stationname: 1,
              regionname: 1,
              alliancename: 1,
              roles: 1,
              fleetroles: 1
            }
          });
        }
      }, {
        find: function(waitlist) {
          if (!((waitlist != null) && (waitlist.booster != null))) {
            return;
          }
          return Characters.find({
            _id: waitlist.booster
          }, {
            limit: 1,
            fields: {
              name: 1
            }
          });
        }
      }, {
        find: function(waitlist) {
          return Characters.find({
            $or: [
              {
                roles: 'booster'
              }, {
                roles: 'manager'
              }
            ],
            active: true,
            waitlist: null
          }, {
            fields: {
              name: 1,
              roles: 1,
              active: 1,
              fleetroles: 1
            }
          });
        }
      }, {
        find: function(waitlist) {
          if (!((waitlist != null) && (waitlist.manager != null))) {
            return;
          }
          return Characters.find({
            _id: waitlist.manager
          }, {
            limit: 1,
            fields: {
              name: 1
            }
          });
        }
      }, {
        find: function(waitlist) {
          if (!((waitlist != null) && (waitlist.booster != null))) {
            return;
          }
          return Characters.find({
            _id: {
              $in: waitlist.booster
            },
            active: false
          }, {
            fields: {
              name: 1
            }
          });
        }
      }
    ]
  };
});

Meteor.publish('fits', function() {
  return Fits.find();
});

Meteor.publish('eventlog', function() {
  return EventLog.find({}, {sort: {time: -1}, limit: 100});
});

Meteor.publish(null, function(): any {
  return [Settings.find({}), Roles.find({})];
});

Meteor.publish('admin', function(): any {
  let uid = this.userId;
  if (!uid) {
    return [];
  }
  let chara = Characters.findOne({
    uid: uid,
  });
  if (!((chara != null) &&
        (chara.roles != null) &&
        (chara.roles.indexOf('admin') >= 0))) {
    return [];
  }
  return Characters.find({}, {
    fields: {
      shiptype: 1,
      system: 1,
      systemid: 1,
      corpname: 1,
      alliancename: 1,
      banned: 1,
      roles: 1,
      shipname: 1,
      regionname: 1,
      name: 1,
      corpid: 1,
      allianceid: 1,
      shiptypeid: 1,
      stationname: 1,
      stationid: 1,
      fits: 1,
      active: 1,
      fleetroles: 1,
      logifive: 1
    }
  });
});

Meteor.publish('profile', function(charId: number): any {
  let uid = this.userId;
  if (!uid) {
    return [];
  }
  let chara: ICharacter = Characters.findOne({
     uid: '' + uid,
  });
  if (!((chara != null) && (chara.roles != null) && chara.roles.indexOf('admin') >= 0)) {
    return [];
  }
  return EventLog.find({
    charid: charId
  });
});
