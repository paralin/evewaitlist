Fiber = Npm.require 'fibers'

#remove temp stuff on start
TrustStatus.remove({})

HTTP.methods
  '/background/update': ->
    headers = @requestHeaders
    hostHash = headers["ident"]
    htrusted = headers["eve_trusted"]
    if !htrusted? or !hostHash?
      @setStatusCode 401
      return "This is a background update method not supported in normal browsers."
    trusted = htrusted is "Yes" and headers["eve_serverip"]?
    oldStatus = TrustStatus.findOne({_id: hostHash})
    trustStatus = {status: trusted}
    TrustStatus.update {_id: hostHash}, {$set: trustStatus}, {upsert: true}
    if oldStatus? && oldStatus.status isnt trusted
      console.log "user "+(if trusted then headers["eve_charname"] else hostHash)+" is now "+(if trusted then "trusted" else "not trusted")

    if !trusted || !hostHash?
      return "Not trusted"

    #parse the new data
    charid = headers["eve_charid"]+""
    if !charid?
      @setStatusCode 500
      return "Your EVE client is submitting invalid data."

    character = Characters.findOne({_id: charid})
    headerData =
      _id: charid
      name: headers["eve_charname"]
      system: headers["eve_solarsystemname"]
      systemid: parseInt headers["eve_solarsystemid"]
      stationname: headers["eve_stationname"]
      stationid: parseInt headers["eve_stationid"]
      corpname: headers["eve_corpname"]
      corpid: parseInt headers["eve_corpid"]
      alliancename: headers["eve_alliancename"]
      allianceid: parseInt headers["eve_allianceid"]
      shipname: headers["eve_shipname"]
      shipid: parseInt headers["eve_shipid"]
      shiptype: headers["eve_shiptypename"]
      shiptypeid: parseInt headers["eve_shiptypeid"]
      corproles: parseInt headers["eve_corprole"]
      waitlist: (if character? then character.waitlist else null)
      hostid: hostHash
      active: true
      lastActiveTime: (new Date).getTime()
      roles: (if character? then character.roles else null)
      fits: (if character? then character.fits else null)

    for k, v of headerData
      headerData[k] = null if v != v || !v?
    
    #find the character object
    if !character?
      console.log "REGISTERED #{headerData.name}"
      Characters.insert headerData
      EventLog.insert
        text: headerData.name+" opened the app for the first time."
        time: new Date()
    else
      #loop over keys, look for changes
      update = {}
      for k,v of character
        headerData[k] = null if v != v || !v?
        if headerData[k] isnt v
          update[k] = headerData[k]
          if not (k in ["hostid", "lastActiveTime", "active"])
            console.log character.name+": "+k+" - "+v+" -> "+headerData[k]
          text = null
          if k is "system"
            text = "#{character.name} jumped from #{v} to #{headerData[k]}."
          if k is "stationname"
            if headerData[k]?
              text = "#{character.name} docked at #{headerData[k]}."
            else
              text = "#{character.name} undocked from #{v}"
          if k is "corpname"
            if headerData[k]?
              text = "#{character.name} joined corp #{headerData[k]}."
            else
              text = "#{character.name} dropped corp #{v}"
          if k is "corproles"
              text = "#{character.name} corp roles changed to #{headerData[k]}"
          if k is "alliancename"
            if headerData[k]?
              text = "#{character.name} joined alliance #{headerData[k]}."
            else
              text = "#{character.name} left alliance #{v}"
          if k is "shipname"
            text = "#{character.name} changed ship name to #{headerData[k]}"
          if k is "shiptype"
            text = "#{character.name} reshipped to #{headerData[k]} from #{v}"
          if text?
            EventLog.insert
              text: text
              time: new Date()
      if Object.keys(update).length
        Characters.update {_id: headerData._id}, {$set: update}
    return "Success"

checkActiveCharacters = ->
  lastAcceptableTime = (new Date().getTime()) - 10*1000
  Characters.update({active: true, lastActiveTime: {$lt: lastAcceptableTime}}, {$set: {active: false}}, {multi: true})

Meteor.setInterval checkActiveCharacters, 5000
checkActiveCharacters()

String::hashCode = ->
  hash = 0
  i = undefined
  chr = undefined
  len = undefined
  return hash  if @length is 0
  i = 0
  len = @length

  while i < len
    chr = @charCodeAt(i)
    hash = ((hash << 5) - hash) + chr
    hash |= 0 # Convert to 32bit integer
    i++
  hash
