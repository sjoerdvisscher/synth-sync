Session.set "synthId", location.pathname.substr(1)

Deps.autorun ->
  Meteor.subscribe "synth", Session.get "synthId"

Meteor.subscribe "components"