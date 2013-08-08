Session.set "synthId", location.pathname

Deps.autorun ->
  Meteor.subscribe "synth", Session.get "synthId"

Meteor.subscribe "components"