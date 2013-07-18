Session.setDefault "jsPlumbReady", no
jsPlumb.ready -> Session.set "jsPlumbReady", yes
Template.main.jsPlumbReady = -> Session.get "jsPlumbReady"

Template.main.boxes = ->
  Boxes.find()
  
Template.main.events
  "click #addBox": ->
    Boxes.insert
      x: 100
      y: 100

  
Template.box.rendered = ->
  jsPlumb.draggable this.firstNode,
    stop: =>
      pos = $(this.firstNode).offset()
      Boxes.update {_id: this.data._id}, {$set:{x: pos.left, y: pos.top}}
      
Template.box.events
  "click .close": ->
    Boxes.remove {_id: this._id}