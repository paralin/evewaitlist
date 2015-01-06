generateCharMsg = (char)->
  """
Dear Morpheus Deathbrew,

Here is my issue report for the problem I'm experiencing:


Sincerely,
#{char.name}
#{gitid}
#{moment().format('MMMM Do YYYY, h:mm:ss a')}
"""

Template.footer.events
  "click .morph": (e)->
    e.preventDefault()
    CCPEVE.showInfo 1377, 90720899
  "click .msgmorph": (e)->
    e.preventDefault()
    CCPEVE.sendMail 90720899, "Waitlist Issue Report", generateCharMsg(Session.get("me"))
