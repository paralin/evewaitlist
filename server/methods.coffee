Meteor.methods
  addFit: (hash, dna)->
    if !dna.endsWith("::") or !dna.startsWith(":")
      throw new Meteor.Error "error", "The ship fit you put in is invalid."
    id = parseInt dna.split(":")[1]
    if !typeids[id]?
      throw new Meteor.Error "error", "The ship referenced in that fit doesn't exist."
    char = Characters.findOne({hostid: hash})
    if !char?
      throw new Meteor.Error "error", "The server does not know about your character."
    char.fits = [] if !char.fits?
    if _.findWhere(char.fits, {dna: dna})?
      throw new Meteor.Error "error", "This fit is already in your list of fits."
    char.fits.push {dna: dna, shipid: id, fid: Random.id()}
    Characters.update {_id: char._id}, {$set: {fits: char.fits}}
  delFit: (hash, fid)->
    char = Characters.findOne({hostid: hash})
    if !char?
      throw new Meteor.Error "error", "The server does not know about your character."
    char.fits = [] if !char.fits?
    fit = _.findWhere(char.fits, {fid: fid})
    if !fit?
      throw new Meteor.Error "error", "Can't find the fit you want to delete"
    char.fits = _.without char.fits, fit
    Characters.update {_id: char._id}, {$set: {fits: char.fits}}
