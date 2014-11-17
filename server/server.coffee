Fiber = Npm.require 'fibers'

#remove temp stuff on start
TrustStatus.remove({})

HTTP.methods
  '/background/update': ->
    headers = @requestHeaders
    if !headers["eve_trusted"]? or !headers["ident"]?
      @setStatusCode 401
      return "This is a background update method not supported in normal browsers."
    trusted = headers["eve_trusted"] is "Yes" and headers["eve_serverip"]?
    hostHash = headers["ident"]
    trustStatus = TrustStatus.findOne({ident: hostHash})
    if !trustStatus?
      trustStatus = {ident: hostHash, status: trusted}
      trustStatus._id = TrustStatus.insert(trustStatus)
    if trustStatus.status isnt trusted
      console.log "user "+(if trusted then headers["eve_charname"] else hostHash)+" is now "+(if trusted then "trusted" else "not trusted")
      trustStatus.status = trusted
      TrustStatus.update({_id: trustStatus._id}, {$set: {status: trusted}})
      @setStatusCode 200
      return ""+hostHash

    if !trusted || !hostHash?
      return

    #parse the new data
    character = Characters.findOne({charId: headers["eve_charid"]})
    headerData =
        charId: headers["eve_charid"]
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
        fleet: (if character? then character.fleet else null)
        hostid: hostHash
        active: true
        lastActiveTime: (new Date).getTime()
        roles: (if character? then character.roles else null)
        fits: (if character? then character.fits else null)

    for k, v of headerData
        headerData[k] = null if v != v || !v?

    #find the character object
    if !character?
      console.log "new character registered: "+headers["eve_charname"]
      headerData._id = Characters.insert(headerData)
    else
      headerData._id = character._id
      changed = false
      #loop over keys, look for changes
      for k,v of character
        if headerData[k] is undefined
          headerData[k] = null
        if headerData[k] isnt v
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
          update = {}
          update[k] = headerData[k]
          if update isnt {}
            Characters.update({_id: character._id}, {$set: update})

checkActiveCharacters = ->
  lastAcceptableTime = (new Date().getTime()) - 10*1000
  Characters.update({active: true, lastActiveTime: {$lt: lastAcceptableTime}}, {$set: {active: false}}, {multi: true})

Meteor.setInterval checkActiveCharacters, 5000
checkActiveCharacters()

String::hashCode = ->
  hash = 0
  i = undefined
  char = undefined
  return hash    if @length is 0
  i = 0
  l = @length

  while i < l
    char = @charCodeAt(i)
    hash = ((hash << 5) - hash) + char
    hash |= 0 # Convert to 32bit integer
    i++
  hash
