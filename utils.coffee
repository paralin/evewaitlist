@filterDna = (input)->
  input.replace (new RegExp("[^0-9;:]", "g")), ""
if typeof String::endsWith isnt "function"
  String::endsWith = (suffix) ->
    @indexOf(suffix, @length - suffix.length) isnt -1
unless typeof String::startsWith is "function"
  String::startsWith = (str) ->
    @indexOf(str) is 0
