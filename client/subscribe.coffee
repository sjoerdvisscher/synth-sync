Session.set "synthId", unescape(location.pathname.substr(1))

Deps.autorun ->
  Meteor.subscribe "synth", Session.get "synthId"

Meteor.subscribe "components"
Meteor.subscribe "synths"

Meteor.setInterval ->
    Session.set "date", new Date
  , 1000