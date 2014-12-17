dnaRegex = /:?(\d+:\d+;)+\d+::/g
@filterDna = (input)->
  matches = input.match dnaRegex
  return "" if matches.length is 0
  matches[0]
if typeof String::endsWith isnt "function"
  String::endsWith = (suffix) ->
    @indexOf(suffix, @length - suffix.length) isnt -1
unless typeof String::startsWith is "function"
  String::startsWith = (str) ->
    @indexOf(str) is 0
