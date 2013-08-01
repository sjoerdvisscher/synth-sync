audioContext = new webkitAudioContext()

nodes = {}

Template.box.created = ->
  console.log "creating: #{@data.name} (#{@data._id})"
  switch @data.name
    when "Microphone"
      navigator.webkitGetUserMedia(
        {audio: true}
        (stream) =>
          nodes[@data._id] = audioContext.createMediaStreamSource stream
        (e) =>
          alert "Error getting audio"
          console.log e
      )
    when "Delay"
      node = audioContext.createDelay(10)
      Deps.autorun =>
        box = Boxes.findOne({_id: @data._id})
        syncInputs node, box
      nodes[@data._id] = node
    when "Gain"
      node = audioContext.createGain()
      Deps.autorun =>
        box = Boxes.findOne({_id: @data._id})
        syncInputs node, box
      nodes[@data._id] = node
    when "Speaker"
      nodes[@data._id] = audioContext.destination
    when "Oscillator"
      node = audioContext.createOscillator()
      Deps.autorun =>
        box = Boxes.findOne({_id: @data._id})
        node.type = box.type
        syncInputs node, box
      node.start(audioContext.currentTime)
      nodes[@data._id] = node
    when "Biquad Filter"
      node = audioContext.createBiquadFilter()
      Deps.autorun =>
        box = Boxes.findOne({_id: @data._id})
        node.type = box.type
        syncInputs node, box
      nodes[@data._id] = node
    else
      console.error "Not implemented: #{@data.name}"
        
syncInputs = (node, box) ->
  for input in box.inputs
    if input.param
      node[input.param].linearRampToValueAtTime input.value, audioContext.currentTime + 0.05


Template.connection.created = ->
  connect @data

connect = (conn) ->
  if not conn.connected
    Meteor.setTimeout((-> connect conn), 100)
  else
    try
      console.log("creating: #{conn.outputBoxId} (#{conn.outputIndex}) -> " +
        "#{conn.inputBoxId} (#{conn.inputParam || conn.inputIndex })")
      if conn.inputParam
        nodes[conn.outputBoxId].connect nodes[conn.inputBoxId][conn.inputParam], conn.outputIndex
      else
        nodes[conn.outputBoxId].connect nodes[conn.inputBoxId], conn.outputIndex, conn.inputIndex
    catch e
      console.log e
      Meteor.call "deleteConn", conn._id

Template.connection.destroyed = ->
  nodes[@data.outputBoxId]?.disconnect()
  Connections.find({ outputBoxId: @data.outputBoxId }).forEach connect
    