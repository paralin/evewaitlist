generateCharMsg = (char)->
  """
Dear Morpheus Deathbrew,

I have an issue to report with the waitlist, iteration 1.0. Here is my issue:


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
