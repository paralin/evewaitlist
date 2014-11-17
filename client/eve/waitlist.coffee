Template.waitlist.helpers
  "fleet": ->
    {
      counts:
        logi: 3
        dps: 6
        other: 9
      fc:
        name: "Skyrider Deathknight"
        avatar: "https://image.eveonline.com/Character/93684586_128.jpg"
    }
  "fits": ->
    [
      {
        dna: "11985:2048;1:1541;1:31366;1:16487;2:2281;1:1964;1:31796;1:3608;4:12058;1:31932;1:2301;1:2488;5::"
        shipid: 11985
      }
    ]
  "shiptype": (id)->
    typeids[id]
  "avatar": (id)->
    "https://image.eveonline.com/Render/#{id}_128.png"
  "character": ->
    Characters.findOne()

Template.waitlist.events
  "click .viewFit": (e)->
    e.preventDefault()
    CCPEVE.showFitting @dna
  "click .removeFit": (e)->
    e.preventDefault()
    Meteor.call "delFit", Session.get("hostHash"), @fid, (err, res)->
      if err?
        $.pnotify
          title: "Can't Delete Fit"
          text: err.reason
          type: "error"
        return
  "click .add-fit": (e)->
    e.preventDefault()
    dna = filterDna $("#addFitInput").val()
    Meteor.call "addFit", Session.get("hostHash"), dna, (err, res)->
      if err?
        $.pnotify
          title: "Invalid ShipDNA"
          text: err.reason
          type: "error"
        return
      $("#addFitInput").val("")
