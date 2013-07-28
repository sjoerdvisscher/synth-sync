@MIDIDevices = new Meteor.Collection null

@addMidiListener = (id, channel, handlers) ->
  console.log "trying"
  if midiAccess is null
    Meteor.setTimeout (-> addMidiListener(id, channel, handlers)), 100
    return
  port = _.find(midiAccess.inputs(), (inp) -> inp.id == id)
  port.onmidimessage = (evt) ->
    return unless channel is -1 or evt.data[0] & 0xF is channel
    console.log evt.data unless evt.data[0] is 254
    switch evt.data[0] & 0xF0
      when 0x80
        handlers.onnoteoff?(evt.data[1])
      when 0x90
        if evt.data[2] is 0
          handlers.onnoteoff?(evt.data[1])
        else
          handlers.onnoteon?(evt.data[1], evt.data[2])
      when 0xc0
        handlers.oncontrolchange?(evt.data[1], evt.data[2])
  
midiAccess = null

Meteor.startup ->
  
  navigator.requestMIDIAccess().then(
    (m) => 
      midiAccess = m
      for port in midiAccess.inputs()
        MIDIDevices.insert
          id: port.id
          name: port.name
      midiAccess.onconnect = (evt) ->
        console.log evt
        MIDIDevices.insert
          id: evt.port.id
          name: evt.port.name
      midiAccess.ondisconnect = (evt) ->
        console.log evt
        _id = MIDIDevices.findOne({id: evt.port.id})._id
        MIDIDevices.remove {_id: _id}
    (err) -> 
      console.error "Could not get MIDI access: #{err}"
  )