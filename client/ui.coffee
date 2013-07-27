Template.main.boxes = ->
  Boxes.find()
Template.main.connections = ->
  Connections.find()
Template.main.components = ->
  Components.find()


dragInfo = 
  startX: 0
  startY: 0
  moveHandler: null
  enterHandler: null
  leaveHandler: null
  upHandler: null
  type: null


Template.main.events

  "click .addComponent": ->
    Boxes.insert _.extend(_.omit(this, "_id"), { x: 100, y: 100 })
        
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



Template.box.nameIs = (name) -> name is @name

Template.box.events

  "click .close": ->
    Meteor.call "deleteBox", @_id

  "mousedown :input, mousemove :input, mouseup :input": (evt) ->
    evt.stopImmediatePropagation()
    
  "mousedown": ->
    dragInfo.moveHandler = (dx, dy) =>
      Boxes.update {_id: @_id}, {$inc: {x: dx, y: dy}}
      
  "mousedown .port": (evt, template) ->
    from = $(evt.target).data "type"
    to = if from is "input" then "output" else "input"
    conn = 
      x: evt.pageX
      y: evt.pageY
    conn[from + "BoxId"] = template.data._id
    conn[from + "Index"] = getIndexByName template.data[from + "s"], @name
    connId = Connections.insert conn
    connected = false
    dragInfo.dropType = to
    dragInfo.moveHandler = (dx, dy) =>
      Connections.update {_id: connId}, {$inc: {x: dx, y: dy}}
    dragInfo.enterHandler = (boxId, name) ->
      props = {}
      props[to + "BoxId"] = boxId
      ports = (Boxes.findOne {_id: boxId})[to + "s"]
      index = getIndexByName ports, name
      props[to + "Index"] = index
      props[to + "Param"] = ports[index].param
      Connections.update {_id: connId}, {$set: props}
      connected = true
    dragInfo.leaveHandler = ->
      props = {}
      props[to + "BoxId"] = null
      props[to + "Index"] = null
      Connections.update {_id: connId}, {$unset: props}
      connected = false
    dragInfo.upHandler = ->
      if connected
        Connections.update {_id: connId}, {$unset: {x: 0, y: 0}}
      else
        Meteor.call "deleteConn", connId
        
  "mouseenter .port": (evt, template) ->
    if dragInfo.enterHandler and $(evt.target).data("type") is dragInfo.dropType
      dragInfo.enterHandler template.data._id, @name
      
  "mouseleave .port": (evt) ->
    if dragInfo.leaveHandler and $(evt.target).data("type") is dragInfo.dropType
      dragInfo.leaveHandler()
  
  "change :input": (evt) ->
    props = {}
    props[evt.target.name] = 1 * evt.target.value
    Boxes.update {_id: @_id}, {$set: props}
  

Template.connection.points = ->
  
  outputBox = Boxes.findOne { _id: @outputBoxId }
  if outputBox
    output = outputBox.outputs[@outputIndex]
    outputX = outputBox.x + 145
    outputY = outputBox.y + (@outputIndex + outputBox.inputs.length)*30 + 51
  else
    outputX = @x
    outputY = @y
  
  inputBox = Boxes.findOne { _id: @inputBoxId }
  if inputBox
    input = inputBox.inputs[@inputIndex]
    inputX = inputBox.x + 25
    inputY = inputBox.y + @inputIndex * 30 + 51
  else
    inputX = @x
    inputY = @y
  
  dx = inputX - outputX
  dy = inputY - outputY
  if isNaN(dx) or isNaN(dy)
    return "M 0 0"
    
  hang = Math.max(dy, 0) + Math.sqrt(dx*dx + dy*dy)/5
  return "M #{outputX} #{outputY} q #{dx / 2} #{hang} #{dx} #{dy}"


Template.connection.dragging = ->
  if @x then "dragging" else ""
  
Template.connection.events
  "click": ->
    Meteor.call "deleteConn", @_id

getIndexByName = (list, name) ->
  _.find _.range(list.length), (i) => list[i].name is name