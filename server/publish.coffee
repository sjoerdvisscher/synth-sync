Meteor.publish "boxes", ->
  Boxes.find {}
Meteor.publish "connections", ->
  Connections.find {}
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
