Template.browserLogin.events
  "submit .form-horizontal": (e)->
    e.preventDefault()
    Meteor.loginWithPassword $("#userInput").val(), $("#password").val(), (err)->
      if err?
        new PNotify
          title: "Invalid Login"
          text: err.reason
          type: "error"
  "click #register": (e)->
    e.preventDefault()
    e.stopImmediatePropagation()
    Accounts.createUser {username: $("#userInput").val(), password: $("#password").val()}, (err)->
      if err?
        new PNotify
          title: "Invalid Sign-up"
          text: err.reason
          type: "error"
