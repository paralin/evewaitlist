@updateCounts = (waitlist)->
  return if !waitlist?
  chars = Characters.find({waitlist: waitlist}, {sort: {waitlistJoinedTime: 1}, fields: {fits: 1, waitlist: 1, waitlistJoinedTime: 1}}).fetch()
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
      pos = 0
      if pfit.shipid in logi
        counts.logi++
        pos = counts.logi
      else if pfit.shipid in dps
        counts.dps++
        pos = counts.dps
      else
        counts.other++
        pos = counts.other
      Characters.update {_id: char._id}, {$set: {waitlistPosition: pos}}
  Waitlists.update({_id: waitlist}, {$set: {stats: counts, used: true}})
@closeWaitlist = (waitlist)->
  return if !waitlist?
  return if waitlist.finished
  console.log "Closing waitlist #{waitlist._id}"
  Characters.update {}, {$set: {waitlist: null}}, {multi: true}
  if !waitlist.used
    Waitlists.remove {_id: waitlist._id}
  else
    Waitlists.update {_id: waitlist._id}, {$set: {finished: true}}
