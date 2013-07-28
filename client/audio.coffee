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
      nodes[@data._id] = audioContext.createDelay(10)
    when "Gain"
      nodes[@data._id] = audioContext.createGain()
    when "Speaker"
      nodes[@data._id] = audioContext.destination
    when "Slider"
      proc = audioContext.createScriptProcessor(1024, 0, 1)
      prevValue = undefined
      proc.onaudioprocess = (evt) =>
        outputArray = evt.outputBuffer.getChannelData(0)
        value = Boxes.findOne({_id: @data._id}).value
        if prevValue is undefined
          prevValue = value
        len = outputArray.length - 1
        delta = value - prevValue
        for i in [0..len]
          outputArray[i] = prevValue + delta * i / len
        prevValue = value
        return
      nodes[@data._id] = proc
    when "Oscillator"
      node = audioContext.createOscillator()
      Deps.autorun =>
        node.type = Boxes.findOne({_id: @data._id}).type
      Deps.autorun =>
        midiInput = Boxes.findOne({_id: @data._id}).midiInput
        if midiInput
          addMidiListener midiInput, -1,
            onnoteon: (note, vel) ->
              node.frequency.setValueAtTime 449 * Math.pow(2, (note - 0x39)/12), audioContext.currentTime
            onnoteoff: (note) ->
              # node.frequency.value = 0
      node.start(audioContext.currentTime)
      nodes[@data._id] = node
    when "Biquad Filter"
      node = audioContext.createBiquadFilter()
      Deps.autorun =>
        node.type = Boxes.findOne({_id: @data._id}).type
      nodes[@data._id] = node
    else
      console.error "Not implemented: #{@data.name}"
        
Template.connection.created = ->
  connect @data

connect = (conn) ->
  if not nodes[conn.outputBoxId] or not nodes[conn.inputBoxId]
    Meteor.setTimeout((-> connect conn), 100)
  else
    try
      console.log("creating: #{conn.outputBoxId} (#{conn.outputIndex}) -> " +
        "#{conn.inputBoxId} (#{conn.inputParam || conn.inputIndex })")
      if conn.inputParam
        nodes[conn.inputBoxId][conn.inputParam].value = 0
        nodes[conn.outputBoxId].connect nodes[conn.inputBoxId][conn.inputParam], conn.outputIndex
      else  
        nodes[conn.outputBoxId].connect nodes[conn.inputBoxId], conn.outputIndex, conn.inputIndex
    catch e
      console.log e
      Meteor.call "deleteConn", conn._id

Template.connection.destroyed = ->
  nodes[@data.outputBoxId]?.disconnect()
  Connections.find({ outputBoxId: @data.outputBoxId }).forEach connect
    