@MIDIDevices = new Meteor.Collection null

@addMidiListener = (id, channel, handlers) ->
  
  port = _.find(midiAccess?.inputs(), (inp) -> inp.id == id)
  
  if not port
    Meteor.setTimeout (-> addMidiListener(id, channel, handlers)), 100
    return
  
  port.onmidimessage = (evt) ->
    
    return unless channel is -1 or evt.data[0] & 0xF is channel
    
    # console.log evt.data unless evt.data[0] is 254
    
    switch evt.data[0] & 0xF0
      
      when 0x80
        handlers.onnoteoff?(evt.data[1])
      
      when 0x90
        if evt.data[2] is 0
          handlers.onnoteoff?(evt.data[1])
        else
          handlers.onnoteon?(evt.data[1], evt.data[2])
      
      when 0xB0
        handlers.oncontrolchange?(evt.data[1], evt.data[2])

      when 0xE0
        handlers.onpitchwheelchange?(((evt.data[1] & 0x7F) + 128 * (evt.data[2] & 0x7F)) / 0x2000 - 1)


midiAccess = null

Meteor.startup ->
  
  navigator.requestMIDIAccess().then(
    (m) => 
      midiAccess = m
    
      for port in midiAccess.inputs()
        
        MIDIDevices.insert
          id: port.id
          name: port.name
        
        do (port) -> 
          @addMidiListener port.id, -1,
            
            onnoteon: (note, velocity) ->
              freq = 440 * Math.pow(2, (note - 69) / 12)
              Boxes.find({name: "Oscillator", midiInput: port.id}).forEach (box) ->
                Boxes.update {_id: box._id}, {$set: {"inputs.0.value": freq }}
            
            onpitchwheelchange: (change) -> 
              Boxes.find({name: "Oscillator", midiInput: port.id}).forEach (box) ->
                detune = box.inputs[1]
                value = (change + 1) / 2 * (detune.max - detune.min) + detune.min
                Boxes.update {_id: box._id}, {$set: {"inputs.1.value": value}}
            
            oncontrolchange: (control, value) ->
              if midiLearning and lastActiveRangeInput
                rangeInputs[control] = lastActiveRangeInput
              inp = rangeInputs[control]
              if inp
                inp.value = inp.min + (inp.max - inp.min) * value / 127

    
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

midiLearning = off

lastActiveRangeInput = null
rangeInputs = {}

Meteor.setInterval(
  -> 
    for control, inp of rangeInputs
      props = {}
      props[inp.name] = inp.value
      Boxes.update {_id: inp._id}, {$set: props}
  50
)

Template.box.events

  "mousedown .range": (evt, template) ->
    $tgt = $(evt.target)
    lastActiveRangeInput = 
      _id: template.data._id
      name: $tgt.data "param"
      min: 1*$tgt.data "min"
      max: 1*$tgt.data "max"

Template.main.events
  
  "click [data-role=midi-learning-on]": ->
    midiLearning = on
  "click [data-role=midi-learning-off]": ->
    midiLearning = off
    