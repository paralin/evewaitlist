logi = [11978, 11985]
dps = [17740, 17736, 24690, 641, 17728, 17738, 17732, 639, 24694, 32305, 643, 17636, 28710, 638]
@updateCounts = (waitlist)->
  return if !waitlist?
  chars = Characters.find({waitlist: waitlist}).fetch()
  counts =
    logi: 0
    other: 0
    dps: 0
  for char in chars
    pfit = _.findWhere char.fits, {primary: true}
    if !pfit?
      if char.fits.length > 0
        char.fits[0].primary = true
        Characters.update({_id: char._id}, {$set: {fits: char.fits}})
      else
        Characters.update({_id: char._id}, {$set: {waitlist: null}})
    else
      if pfit.shipid in logi
        counts.logi++
      else if pfit.shipid in dps
        counts.dps++
      else
        counts.other++
  Waitlists.update({_id: waitlist}, {$set: {stats: counts}})
@closeWaitlist = (waitlist)->
  return if !waitlist?
  return if waitlist.finished
  console.log "Closing waitlist #{waitlist._id}"
  Waitlists.update {_id: waitlist._id}, {$set: {finished: true}}
