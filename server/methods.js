var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

Meteor.methods({
  validateHostHash: function() {
    var char;
    char = Characters.findOne({
      uid: this.userId
    });
    if (char == null) {
      throw new Meteor.Error("error", "The server does not know about that character.");
    }
    return true;
  },
  setComment: function(comment) {
    var char, fit;
    check(comment, String);
    comment = comment.replace(/[^\w\s]/gi, '');
    char = Characters.findOne({
      uid: this.userId
    });
    if (char == null) {
      throw new Meteor.Error("error", "The server does not know about your character.");
    }
    fit = _.findWhere(char.fits, {
      fid: id
    });
    if (fit == null) {
      throw new Meteor.Error("error", "Can't find that fit in your fits.");
    }
    return Characters.update({
      _id: char._id,
      "fits.fid": id
    }, {
      $set: {
        "fits.$.comment": comment
      }
    });
  },
  addFit: function(dna) {
    var char, fit, id;
    check(dna, String);
    dna = filterDna(dna);
    if (dna.length < 10 || dna.indexOf("::") === -1) {
      throw new Meteor.Error("error", "The ship fit you put in is invalid.");
    }
    id = parseInt(dna.split(":")[1]);
    if (typeids[id] == null) {
      throw new Meteor.Error("error", "The ship referenced in that fit doesn't exist.");
    }
    char = Characters.findOne({
      uid: this.userId
    });
    if (char == null) {
      throw new Meteor.Error("error", "The server does not know about your character.");
    }
    if (char.fits == null) {
      char.fits = [];
    }
    if (_.findWhere(char.fits, {
      dna: dna
    }) != null) {
      throw new Meteor.Error("error", "You already have that exact fit in your fit list.");
    }
    fit = {
      dna: dna,
      shipid: id,
      fid: Random.id(),
      primary: char.fits.length === 0,
      comment: ""
    };
    return Characters.update({
      _id: char._id
    }, {
      $push: {
        fits: fit
      }
    });
  },
  delFit: function(fid) {
    var char, fit;
    check(fid, String);
    char = Characters.findOne({
      uid: this.userId
    });
    if (char == null) {
      throw new Meteor.Error("error", "The server does not know about your character.");
    }
    if (char.fits == null) {
      char.fits = [];
    }
    fit = _.findWhere(char.fits, {
      fid: fid
    });
    if (fit == null) {
      throw new Meteor.Error("error", "Can't find the fit you want to delete");
    }
    char.fits = _.without(char.fits, fit);
    Characters.update({
      _id: char._id
    }, {
      $pull: {
        fits: {
          fid: fid
        }
      }
    });
    if (fit.primary && char.fits.length > 0) {
      Characters.update({
        _id: char._id,
        "fits.fid": char.fits[0].fid
      }, {
        $set: {
          "fits.$.primary": true
        }
      });
    }
    if (char.fits.length === 0) {
      Characters.update({
        _id: char._id
      }, {
        $set: {
          waitlist: null
        }
      });
    }
    return updateCounts(char.waitlist);
  },
  setPrimary: function(id) {
    var char, fit;
    check(id, String);
    char = Characters.findOne({
      uid: this.userId
    });
    if (char == null) {
      throw new Meteor.Error("error", "The server does not know about your character.");
    }
    fit = _.findWhere(char.fits, {
      fid: id
    });
    if (fit == null) {
      throw new Meteor.Error("error", "Can't find the fit you want to make primary.");
    }
    Characters.update({
      _id: char._id,
      "fits.primary": true
    }, {
      $set: {
        "fits.$.primary": false
      }
    });
    Characters.update({
      _id: char._id,
      "fits.fid": id
    }, {
      $set: {
        "fits.$.primary": true
      }
    });
    if (char.waitlist != null) {
      return updateCounts(char.waitlist);
    }
  },
  joinWaitlist: function(id) {
    var char, waitlist;
    check(id, String);
    char = Characters.findOne({
      uid: this.userId
    });
    if (char == null) {
      throw new Meteor.Error("error", "The server does not know about your character.");
    }
    waitlist = Waitlists.findOne({
      _id: id
    });
    if (waitlist == null) {
      throw new Meteor.Error("error", "There is no waitlist by that ID");
    }
    if (waitlist.commander === char._id || waitlist.manager === char._id) {
      throw new Meteor.Error("error", "You can't join because you're in a management position.");
    }
    if ((char.fits == null) || char.fits.length === 0) {
      throw new Meteor.Error("error", "You must have at least one fit to join.");
    }
    Characters.update({
      _id: char._id
    }, {
      $set: {
        waitlist: waitlist._id,
        waitlistJoinedTime: new Date().getTime()
      }
    });
    return updateCounts(waitlist._id);
  },
  leaveWaitlist: function() {
    var char;
    char = Characters.findOne({
      uid: this.userId
    });
    if (char == null) {
      throw new Meteor.Error("error", "The server does not know about your character.");
    }
    if (char.waitlist != null) {
      Characters.update({
        _id: char._id
      }, {
        $set: {
          waitlist: null
        }
      });
      return updateCounts(char.waitlist);
    }
  },
  setCurrentSystem: function() {
    var char;
    char = Characters.findOne({
      uid: this.userId
    });
    if ((char == null) || (char.systemid == null)) {
      throw new Meteor.Error("error", "The server does not know about your character.");
    }
    if (!((char.roles != null) && indexOf.call(char.roles, "admin") >= 0)) {
      throw new Meteor.Error("error", "You are not authorized to perform this action.");
    }
    return Settings.update({
      _id: "incursion"
    }, {
      $set: {
        sysid: char.systemid,
        sysname: char.system
      }
    });
  },
  addRole: function(cid, role) {
    var char, ref, ro, tchar;
    check(cid, String);
    check(role, String);
    ro = Roles.findOne({
      _id: role
    });
    if (ro == null) {
      throw new Meteor.Error("error", "There is no role by that ID.");
    }
    if (ro["protected"]) {
      throw new Meteor.Error("error", "You cannot update that role through the web UI.");
    }
    char = Characters.findOne({
      uid: this.userId
    });
    if (char == null) {
      throw new Meteor.Error("error", "The server does not know about your character.");
    }
    if (!((char.roles != null) && indexOf.call(char.roles, "admin") >= 0)) {
      throw new Meteor.Error("error", "You are not authorized to perform this action.");
    }
    tchar = Characters.findOne({
      _id: cid
    });
    if (tchar == null) {
      throw new Meteor.Error("error", "Can't find the character you want to update.");
    }
    if (tchar.roles == null) {
      tchar.roles = [ro._id];
    } else if (!(ref = ro._id, indexOf.call(tchar.roles, ref) >= 0)) {
      tchar.roles.push(ro._id);
    } else {
      return;
    }
    return Characters.update({
      _id: tchar._id
    }, {
      $set: {
        roles: tchar.roles
      }
    });
  },
  removeRole: function(cid, role) {
    var char, ref, ro, tchar;
    check(cid, String);
    check(role, String);
    ro = Roles.findOne({
      _id: role
    });
    if (ro == null) {
      throw new Meteor.Error("error", "There is no role by that ID.");
    }
    if (ro["protected"]) {
      throw new Meteor.Error("error", "You cannot update that role through the web UI.");
    }
    char = Characters.findOne({
      uid: this.userId
    });
    if (char == null) {
      throw new Meteor.Error("error", "The server does not know about your character.");
    }
    if (!((char.roles != null) && indexOf.call(char.roles, "admin") >= 0)) {
      throw new Meteor.Error("error", "You are not authorized to perform this action.");
    }
    tchar = Characters.findOne({
      _id: cid
    });
    if (tchar == null) {
      throw new Meteor.Error("error", "Can't find the character you want to update.");
    }
    if (tchar.roles == null) {
      tchar.roles = [];
    } else if ((ref = ro._id, indexOf.call(tchar.roles, ref) >= 0)) {
      tchar.roles = _.without(tchar.roles, ro._id);
    } else {
      return;
    }
    return Characters.update({
      _id: tchar._id
    }, {
      $set: {
        roles: tchar.roles
      }
    });
  },
  adminCloseWaitlist: function() {
    var char, waitlist;
    char = Characters.findOne({
      uid: this.userId
    });
    if (char == null) {
      throw new Meteor.Error("error", "The server does not know about your character.");
    }
    if (!((char.roles != null) && indexOf.call(char.roles, "admin") >= 0)) {
      throw new Meteor.Error("error", "You are not authorized to perform this action.");
    }
    waitlist = Waitlists.findOne({
      finished: false
    });
    if (waitlist == null) {
      throw new Meteor.Error("error", "There is no active waitlist.");
    }
    return closeWaitlist(waitlist);
  },
  banCharacter: function(cid) {
    var char, uchar;
    char = Characters.findOne({
      uid: this.userId
    });
    if (char == null) {
      throw new Meteor.Error("error", "The server does not know about your character.");
    }
    if (!((char.roles != null) && indexOf.call(char.roles, "admin") >= 0)) {
      throw new Meteor.Error("error", "You are not authorized to perform this action.");
    }
    uchar = Characters.findOne({
      _id: cid
    });
    if (uchar == null) {
      throw new Meteor.Error("error", "Cannot find the character.");
    }
    if ((uchar.roles != null) && indexOf.call(uchar.roles, "admin") >= 0) {
      throw new Meteor.Error("error", "You cannot ban an admin.");
    }
    return Characters.update({
      _id: uchar._id
    }, {
      $set: {
        banned: true
      },
      $unset: {
        roles: ""
      }
    });
  },
  unbanCharacter: function(cid) {
    var char, uchar;
    char = Characters.findOne({
      uid: this.userId
    });
    if (char == null) {
      throw new Meteor.Error("error", "The server does not know about your character.");
    }
    if (!((char.roles != null) && indexOf.call(char.roles, "admin") >= 0)) {
      throw new Meteor.Error("error", "You are not authorized to perform this action.");
    }
    uchar = Characters.findOne({
      _id: cid
    });
    if (uchar == null) {
      throw new Meteor.Error("error", "Cannot find the character.");
    }
    return Characters.update({
      _id: uchar._id
    }, {
      $set: {
        banned: false
      },
      $unset: {
        roles: ""
      }
    });
  },
  closeWaitlist: function() {
    var char, waitlist;
    char = Characters.findOne({
      uid: this.userId
    });
    if (char == null) {
      throw new Meteor.Error("error", "The server does not know about your character.");
    }
    waitlist = Waitlists.findOne({
      finished: false
    });
    if (waitlist == null) {
      throw new Meteor.Error("error", "There is no active waitlist.");
    }
    if (!((char.roles != null) && indexOf.call(char.roles, "command") >= 0 && waitlist.commander === char._id)) {
      throw new Meteor.Error("error", "You are not authorized to perform this action.");
    }
    return closeWaitlist(waitlist);
  },
  openWaitlist: function() {
    var char, waitlist;
    char = Characters.findOne({
      uid: this.userId
    });
    if (char == null) {
      throw new Meteor.Error("error", "The server does not know about your character.");
    }
    if (!((char.roles != null) && ((indexOf.call(char.roles, "command") >= 0) || (indexOf.call(char.roles, "admin") >= 0)))) {
      throw new Meteor.Error("error", "You are not an admin or a fleet commander.");
    }
    waitlist = Waitlists.findOne({
      finished: false
    });
    if (waitlist != null) {
      throw new Meteor.Error("error", "There is already an active waitlist.");
    }
    return openWaitlist(char);
  },
  deleteFromWaitlist: function(cid, accepted, reason) {
    var char, tchar, waitlist;
    check(accepted, Boolean);
    check(cid, String);
    if (!accepted) {
      check(reason, String);
    }
    char = Characters.findOne({
      uid: this.userId
    });
    if (char == null) {
      throw new Meteor.Error("error", "The server does not know about your character.");
    }
    if (!((char.roles != null) && ((indexOf.call(char.roles, "command") >= 0) || (indexOf.call(char.roles, "admin") >= 0) || (indexOf.call(char.roles, "manager") >= 0)))) {
      throw new Meteor.Error("error", "You are not an admin or a fleet manager.");
    }
    waitlist = Waitlists.findOne({
      finished: false,
      $or: [
        {
          commander: char._id
        }, {
          manager: char._id
        }
      ]
    });
    if (waitlist == null) {
      throw new Meteor.Error("error", "You are not a commander of the waitlist.");
    }
    tchar = Characters.findOne({
      _id: cid,
      waitlist: waitlist._id
    });
    if (tchar == null) {
      throw new Meteor.Error("error", "Can't find that character.");
    }
    Characters.update({
      _id: cid
    }, {
      $set: {
        waitlist: null,
        waitlistJoinedTime: null
      }
    });
    return updateCounts(waitlist._id);
  },
  setBooster: function(cid) {
    var boost, char, tchar, waitlist;
    check(cid, String);
    char = Characters.findOne({
      uid: this.userId
    });
    if (char == null) {
      throw new Meteor.Error("error", "The server does not know about your character.");
    }
    if (!((char.roles != null) && ((indexOf.call(char.roles, "command") >= 0) || (indexOf.call(char.roles, "admin") >= 0)))) {
      throw new Meteor.Error("error", "You are not an admin or a fleet manager.");
    }
    waitlist = Waitlists.findOne({
      finished: false,
      $or: [
        {
          commander: char._id
        }
      ]
    });
    if (waitlist == null) {
      throw new Meteor.Error("error", "You are not a commander of the waitlist.");
    }
    tchar = Characters.findOne({
      _id: cid
    });
    if (tchar == null) {
      throw new Meteor.Error("error", "Can't find that character.");
    }
    if (!((tchar.roles != null) && indexOf.call(tchar.roles, "booster") >= 0)) {
      throw new Meteor.Error("error", "That character is not a booster.");
    }
    boost = waitlist.booster || [];
    if (_.contains(boost, tchar._id)) {
      throw new Meteor.Error("error", "That booster already is set.");
    }
    boost.push(tchar._id);
    return Waitlists.update({
      _id: waitlist._id
    }, {
      $set: {
        booster: boost
      }
    });
  },
  removeBooster: function() {
    var char, waitlist;
    char = Characters.findOne({
      uid: this.userId
    });
    if (char == null) {
      throw new Meteor.Error("error", "The server does not know about your character.");
    }
    if (!((char.roles != null) && ((indexOf.call(char.roles, "command") >= 0) || (indexOf.call(char.roles, "admin") >= 0)))) {
      throw new Meteor.Error("error", "You are not an admin or a fleet manager.");
    }
    waitlist = Waitlists.findOne({
      finished: false,
      $or: [
        {
          commander: char._id
        }
      ]
    });
    if (waitlist == null) {
      throw new Meteor.Error("error", "You are not a commander of the waitlist.");
    }
    if (waitlist.booster == null) {
      throw new Meteor.Error("error", "There is no booster set.");
    }
    return Waitlists.update({
      _id: waitlist._id
    }, {
      $set: {
        booster: null
      }
    });
  },
  setManager: function(cid) {
    var char, tchar, waitlist;
    check(cid, String);
    char = Characters.findOne({
      uid: this.userId
    });
    if (char == null) {
      throw new Meteor.Error("error", "The server does not know about your character.");
    }
    if (!((char.roles != null) && ((indexOf.call(char.roles, "command") >= 0) || (indexOf.call(char.roles, "admin") >= 0) || (indexOf.call(char.roles, "manager") >= 0)))) {
      throw new Meteor.Error("error", "You are not an admin or a waitlist manager or a commander.");
    }
    waitlist = Waitlists.findOne({
      finished: false,
      $or: [
        {
          commander: char._id
        }, {
          manager: char._id
        }
      ]
    });
    if (waitlist == null) {
      throw new Meteor.Error("error", "You are not a commander of the waitlist.");
    }
    tchar = Characters.findOne({
      _id: cid
    });
    if (tchar == null) {
      throw new Meteor.Error("error", "Can't find that character.");
    }
    if (!((tchar.roles != null) && indexOf.call(tchar.roles, "manager") >= 0)) {
      throw new Meteor.Error("error", "That character is not a manager.");
    }
    if (waitlist.manager != null) {
      throw new Meteor.Error("error", "There already is a manager.");
    }
    return Waitlists.update({
      _id: waitlist._id
    }, {
      $set: {
        manager: tchar._id
      }
    });
  },
  removeManager: function() {
    var char, waitlist;
    char = Characters.findOne({
      uid: this.userId
    });
    if (char == null) {
      throw new Meteor.Error("error", "The server does not know about your character.");
    }
    if (!((char.roles != null) && ((indexOf.call(char.roles, "manager") >= 0) || (indexOf.call(char.roles, "admin") >= 0) || (indexOf.call(char.roles, "command") >= 0)))) {
      throw new Meteor.Error("error", "You are not an admin or a fleet manager or a commander.");
    }
    waitlist = Waitlists.findOne({
      finished: false,
      $or: [
        {
          manager: char._id
        }, {
          commander: char._id
        }
      ]
    });
    if (waitlist == null) {
      throw new Meteor.Error("error", "You are not a commander of the waitlist.");
    }
    return Waitlists.update({
      _id: waitlist._id
    }, {
      $set: {
        manager: null
      }
    });
  },
  setLogiLvl: function(lvl) {
    var char;
    check(lvl, Boolean);
    char = Characters.findOne({
      uid: this.userId
    });
    if (char == null) {
      throw new Meteor.Error("error", "The server does not know about your character.");
    }
    return Characters.update({
      _id: char._id
    }, {
      $set: {
        logifive: lvl
      }
    });
  },
  setRoles: function(roles) {
    var char;
    char = Characters.findOne({
      uid: this.userId
    });
    if (char == null) {
      throw new Meteor.Error("error", "The server does not know about your character.");
    }
    return Characters.update({
      _id: char._id
    }, {
      $set: {
        fleetroles: roles
      }
    });
  },
  becomeFC: function(id) {
    var char, upd, waitlist;
    check(id, String);
    char = Characters.findOne({
      uid: this.userId
    });
    if (char == null) {
      throw new Meteor.Error("error", "The server does not know about your character.");
    }
    if (!((char.roles != null) && (indexOf.call(char.roles, "command") >= 0))) {
      throw new Meteor.Error("error", "You are not a fleet commander.");
    }
    waitlist = Waitlists.findOne({
      finished: false,
      _id: id
    });
    if (waitlist == null) {
      throw new Meteor.Error(404, "Can't find that waitlist.");
    }
    if (waitlist.commander === char._id) {
      throw new Meteor.Error(404, "You are already the commander.");
    }
    upd = {
      $set: {
        commander: char._id
      }
    };
    if (waitlist.manager === char._id) {
      upd.$set.manager = null;
    }
    return Waitlists.update({
      _id: waitlist._id
    }, upd);
  }
  });
