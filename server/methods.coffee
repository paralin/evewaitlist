Meteor.methods
  addFit: (hash, dna)->
    check hash, String
    check dna, String
    dna = filterDna dna
    if dna.length < 10 or dna.indexOf("::") is -1
      throw new Meteor.Error "error", "The ship fit you put in is invalid."
    id = parseInt dna.split(":")[1]
    if !typeids[id]?
      throw new Meteor.Error "error", "The ship referenced in that fit doesn't exist."
    char = Characters.findOne({hostid: hash})
    if !char?
      throw new Meteor.Error "error", "The server does not know about your character."
    char.fits = [] if !char.fits?
    if _.findWhere(char.fits, {dna: dna})?
      throw new Meteor.Error "error", "You already have that exact fit in your fit list."
    char.fits.push {dna: dna, shipid: id, fid: Random.id(), primary: char.fits.length==0}
    Characters.update {_id: char._id}, {$set: {fits: char.fits}}
  delFit: (hash, fid)->
    check hash, String
    check fid, String
    char = Characters.findOne({hostid: hash})
    if !char?
      throw new Meteor.Error "error", "The server does not know about your character."
    char.fits = [] if !char.fits?
    fit = _.findWhere(char.fits, {fid: fid})
    if !fit?
      throw new Meteor.Error "error", "Can't find the fit you want to delete"
    char.fits = _.without char.fits, fit
    char.fits[0].primary = true if fit.primary and char.fits.length > 0
    update = {fits: char.fits}
    if char.fits.length is 0
      update["waitlist"] = null
    Characters.update {_id: char._id}, {$set: update}
    updateCounts(char.waitlist)
  setPrimary: (hash, id)->
    check hash, String
    check id, String
    char = Characters.findOne({hostid: hash})
    if !char?
      throw new Meteor.Error "error", "The server does not know about your character."
    fit = _.findWhere char.fits, {fid: id}
    if !fit?
      throw new Meteor.Error "error", "Can't find the fit you want to make primary."
    for fi in char.fits
      fi.primary = fi is fit
    Characters.update {_id: char._id}, {$set: {fits: char.fits}}
    if char.waitlist?
      updateCounts(char.waitlist)
  joinWaitlist: (hash, id)->
    check hash, String
    check id, String
    char = Characters.findOne({hostid: hash})
    if !char?
      throw new Meteor.Error "error", "The server does not know about your character."
    waitlist = Waitlists.findOne {_id: id}
    if !waitlist?
      throw new Meteor.Error "error", "There is no waitlist by that ID"
    if !char.fits? or char.fits.length is 0
      throw new Meteor.Error "error", "You must have at least one fit to join."
    Characters.update {_id: char._id}, {$set: {waitlist: waitlist._id}}
    updateCounts(waitlist._id)
  leaveWaitlist: (hash)->
    check hash, String
    char = Characters.findOne({hostid: hash})
    if !char?
      throw new Meteor.Error "error", "The server does not know about your character."
    if char.waitlist?
      Characters.update {_id: char._id}, {$set: {waitlist: null}}
      updateCounts(char.waitlist)
  setCurrentSystem: (hash)->
    check hash, String
    char = Characters.findOne({hostid: hash})
    if !char?
      throw new Meteor.Error "error", "The server does not know about your character."
    unless char.roles? and "admin" in char.roles
      throw new Meteor.Error "error", "You are not authorized to perform this action."
    Settings.update {_id: "incursion"}, {$set: {sysid: char.systemid, sysname: char.system}}
  addRole: (hash, cid, role)->
    check hash, String
    check cid, String
    check role, String
    ro = Roles.findOne {_id: role}
    if !ro?
      throw new Meteor.Error "error", "There is no role by that ID."
    if ro.protected
      throw new Meteor.Error "error", "You cannot update that role through the web UI."
    char = Characters.findOne {hostid: hash}
    if !char?
      throw new Meteor.Error "error", "The server does not know about your character."
    unless char.roles? and "admin" in char.roles
      throw new Meteor.Error "error", "You are not authorized to perform this action."
    tchar = Characters.findOne {_id: cid}
    if !tchar?
      throw new Meteor.Error "error", "Can't find the character you want to update."
    if !tchar.roles?
      tchar.roles = [ro._id]
    else if !(ro._id in tchar.roles)
      tchar.roles.push ro._id
    else
      return
    Characters.update {_id: tchar._id}, {$set: {roles: tchar.roles}}
  removeRole: (hash, cid, role)->
    check hash, String
    check cid, String
    check role, String
    ro = Roles.findOne {_id: role}
    if !ro?
      throw new Meteor.Error "error", "There is no role by that ID."
    if ro.protected
      throw new Meteor.Error "error", "You cannot update that role through the web UI."
    char = Characters.findOne {hostid: hash}
    if !char?
      throw new Meteor.Error "error", "The server does not know about your character."
    unless char.roles? and "admin" in char.roles
      throw new Meteor.Error "error", "You are not authorized to perform this action."
    tchar = Characters.findOne {_id: cid}
    if !tchar?
      throw new Meteor.Error "error", "Can't find the character you want to update."
    if !tchar.roles?
      tchar.roles = []
    else if (ro._id in tchar.roles)
      tchar.roles = _.without tchar.roles, ro._id
    else
      return
    Characters.update {_id: tchar._id}, {$set: {roles: tchar.roles}}
