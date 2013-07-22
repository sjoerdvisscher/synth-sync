Template.main.boxes = ->
  Boxes.find()
Template.main.connections = ->
  Connections.find()


dragInfo = 
  startX: 0
  startY: 0
  moveHandler: null
  enterHandler: null
  leaveHandler: null
  upHandler: null
  type: null


Template.main.events

  "click #addBox": ->
    Boxes.insert
      x: 100
      y: 100
      inputs: [{ name: "Audio In", x: 20, y: 20 }]
      outputs: [{ name: "Audio Out", x: 20, y: 50 }]
        
  "mousedown": (evt) ->
    dragInfo.startX = evt.pageX
    dragInfo.startY = evt.pageY
    
  "mousemove": (evt) ->
    if dragInfo.moveHandler
      dragInfo.moveHandler evt.pageX - dragInfo.startX, evt.pageY - dragInfo.startY
      dragInfo.startX = evt.pageX
      dragInfo.startY = evt.pageY
      
  "mouseup": ->
    if dragInfo.upHandler
      dragInfo.upHandler()
    dragInfo.moveHandler = null
    dragInfo.enterHandler = null
    dragInfo.leaveHandler = null
    dragInfo.upHandler = null



Template.box.events

  "click .close": ->
    Meteor.call "deleteBox", this._id
    
  "mousedown": ->
    dragInfo.moveHandler = (dx, dy) =>
      Boxes.update {_id: this._id}, {$inc: {x: dx, y: dy}}
      
  "mousedown .port": (evt, template) ->
    from = $(evt.target).data "type"
    to = if from is "input" then "output" else "input"
    conn = 
      x: evt.pageX
      y: evt.pageY
    conn[from + "BoxId"] = template.data._id
    conn[from + "Name"] = this.name
    connId = Connections.insert conn
    connected = false
    dragInfo.dropType = to
    dragInfo.moveHandler = (dx, dy) =>
      Connections.update {_id: connId}, {$inc: {x: dx, y: dy}}
    dragInfo.enterHandler = (boxId, name) ->
      props = {}
      props[to + "BoxId"] = boxId
      props[to + "Name"] = name
      Connections.update {_id: connId}, {$set: props}
      connected = true
    dragInfo.leaveHandler = ->
      props = {}
      props[to + "BoxId"] = null
      props[to + "Name"] = null
      Connections.update {_id: connId}, {$unset: props}
      connected = false
    dragInfo.upHandler = ->
      if connected
        Connections.update {_id: connId}, {$unset: {x: 0, y: 0}}
      else
        Meteor.call "deleteConn", connId
        
  "mouseenter .port": (evt, template) ->
    if dragInfo.enterHandler and $(evt.target).data("type") is dragInfo.dropType
      dragInfo.enterHandler template.data._id, this.name
      
  "mouseleave .port": (evt) ->
    if dragInfo.leaveHandler and $(evt.target).data("type") is dragInfo.dropType
      dragInfo.leaveHandler()


Template.connection.points = ->
  outputBox = Boxes.findOne {_id: this.outputBoxId }
  if outputBox
    output = _.find outputBox.outputs, (inp) => inp.name is this.outputName
    outputX = outputBox.x + output.x + 100 - 10 + 1
    outputY = outputBox.y + output.y + 11
  else
    outputX = this.x
    outputY = this.y
  inputBox = Boxes.findOne {_id: this.inputBoxId }
  if inputBox
    input = _.find inputBox.inputs, (inp) => inp.name is this.inputName
    inputX = inputBox.x + input.x + 11
    inputY = inputBox.y + input.y + 11
  else
    inputX = this.x
    inputY = this.y
  dx = inputX - outputX
  dy = inputY - outputY
  hang = Math.max(dy, 0) + 200
  return "M " + outputX + " " + outputY + " q " + dx / 2 + " " + hang + " " + dx + " " + dy

Template.connection.dragging = ->
  if this.x then "dragging" else ""
  
Template.connection.events
  "click": ->
    Meteor.call "deleteConn", this._id
