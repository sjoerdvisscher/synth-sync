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
      nodes[@data._id] = audioContext.createDelay(10)
      nodes[@data._id].delayTime.value = 0.2
    when "Gain"
      nodes[@data._id] = audioContext.createGain()
      nodes[@data._id].gain.value = 1
    when "Speaker"
      nodes[@data._id] = audioContext.destination
    when "Slider"
      proc = audioContext.createScriptProcessor(256, 0, 1)
      proc.onaudioprocess = (evt) =>
        outputArray = evt.outputBuffer.getChannelData(0)
        value = Boxes.findOne({_id: @data._id}).value
        for i in [0..outputArray.length - 1]
          outputArray[i] = value
        return
      nodes[@data._id] = proc
    when "Oscillator"
      osc = audioContext.createOscillator()
      nodes[@data._id] = osc
      osc.type = OscillatorNode.CUSTOM
      Deps.autorun =>
        value = Boxes.findOne({_id: @data._id}).value
        wave = audioContext.createPeriodicWave(new Float32Array [value], new Float32Array [0])
        osc.setPeriodicWave wave
      osc.start()
    else
      console.error "Not implemented: #{@data.name}"
        
Template.connection.created = ->
  connect @data

connect = (conn) ->
  if not nodes[conn.outputBoxId] or not nodes[conn.inputBoxId]
    Meteor.setTimeout((-> connect conn), 100)
  else
    console.log("creating: #{conn.outputBoxId} (#{conn.outputIndex}) -> " +
      "#{conn.inputBoxId} (#{conn.inputParam || conn.inputIndex })")
    if conn.inputParam
      nodes[conn.inputBoxId][conn.inputParam].value = 0
      nodes[conn.outputBoxId].connect nodes[conn.inputBoxId][conn.inputParam], conn.outputIndex
    else  
      nodes[conn.outputBoxId].connect nodes[conn.inputBoxId], conn.outputIndex, conn.inputIndex

Template.connection.destroyed = ->
  nodes[@data.outputBoxId]?.disconnect()
  Connections.find({ outputBoxId: @data.outputBoxId }).forEach connect
    