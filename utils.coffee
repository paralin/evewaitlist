dnaRegex = /:?(\d+:\d+;)+\d+::/g
@filterDna = (input)->
  matches = input.match dnaRegex
  return "" if matches.length is 0
  matches[0]

sysRegex = /<url=showinfo:5\/\/(\d+)>([A-Za-z\d\s]+)<\/url>/igm
@filterSys = (input)->
  matches = []
  continue  while (match = sysRegex.exec(input)) and matches.push({name: match[2], id: parseInt(match[1])})
  return null if matches.length is 0
  matches

if typeof String::endsWith isnt "function"
  String::endsWith = (suffix) ->
    @indexOf(suffix, @length - suffix.length) isnt -1
unless typeof String::startsWith is "function"
  String::startsWith = (str) ->
    @indexOf(str) is 0
