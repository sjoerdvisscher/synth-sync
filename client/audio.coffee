audioContext = new webkitAudioContext()

nodes = {}

Template.box.created = ->
  console.log "creating: #{@data.name} (#{@data._id})"
  switch @data.name
    when "Microphone"
      navigator.webkitGetUserMedia(
        {audio: true}, 
        (stream) =>
          nodes[@data._id] = audioContext.createMediaStreamSource stream
        (e) =>
          alert "Error getting audio"
          console.log e
      )
    when "Delay"
      nodes[@data._id] = audioContext.createDelay()
      nodes[@data._id].delayTime.value = 0.2
    when "Speaker"
      nodes[@data._id] = audioContext.destination
    else
      console.error "Not implemented: #{@data.name}"
        
Template.connection.created = ->
  connect @data

connect = (conn) ->
  if not nodes[conn.outputBoxId] or not nodes[conn.inputBoxId]
    Meteor.setTimeout((-> connect conn), 100)
  else
    console.log "creating: #{conn.outputBoxId} to #{conn.inputBoxId}"
    nodes[conn.outputBoxId].connect nodes[conn.inputBoxId]

Template.connection.destroyed = ->
  nodes[@data.outputBoxId]?.disconnect()
  Connections.find({ outputBoxId: @data.outputBoxId }).forEach connect
    