Template.fits.helpers
  ships: ->
    arr = []
    fits = Fits.find({page: Session.get("igbpage")}).fetch()
    for fit in fits
      existing = _.findWhere(arr, {ship: fit.shiplabel})
      if !existing?
        arr.push
          ship: fit.shiplabel
          fits: [fit]
      else
        existing.fits.push fit
    arr
Template.fits.events
  "click .fitLabel": (e)->
    e.preventDefault()
    showFitting @shipdna
