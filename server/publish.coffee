Meteor.publish "synth", (synthId) ->
  [ Boxes.find({ synthId: synthId })
  , Connections.find({ synthId: synthId })
  ]
Meteor.publish "components", ->
  Components.find {}
  
Meteor.startup ->

  Boxes.allow
    insert: -> yes
    update: -> yes
    remove: -> yes
  
  Connections.allow
    insert: -> yes
    update: -> yes
    remove: -> yes
