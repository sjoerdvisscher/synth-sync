Template.main.boxes = ->
  Boxes.find()

dragInfo = 
  startX: 0
  startY: 0
  startOffset: null
  collection: null
  id: null

Template.main.events
  "click #addBox": ->
    Boxes.insert
      x: 100
      y: 100
  "mousedown": (evt) ->
    dragInfo.startX = evt.pageX
    dragInfo.startY = evt.pageY
  "mousemove": (evt) ->
    if dragInfo.id
      dragInfo.collection.update {_id: dragInfo.id}, {$inc:{x: evt.pageX - dragInfo.startX, y: evt.pageY - dragInfo.startY}}
      dragInfo.startX = evt.pageX
      dragInfo.startY = evt.pageY
  "mouseup": ->
    dragInfo.id = null
    dragInfo.collection = null
  
Template.box.events
  "click .close": ->
    Boxes.remove {_id: this._id}
  "mousedown": (evt) ->
    dragInfo.collection = Boxes
    dragInfo.id = this._id