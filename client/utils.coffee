@arraysEqual = (a, b) ->
  if a == b
    return true
  if a == null or b == null
    return false
  if a.length != b.length
    return false
  # If you don't care about the order of the elements inside
  # the array, you should sort both arrays here.
  i = 0
  while i < a.length
    if a[i] != b[i]
      return false
    ++i
  true
