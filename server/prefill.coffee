Meteor.startup ->
  # Boxes.remove {}
  # Connections.remove {}
  Components.remove {}
  
  Components.insert
    name: "Microphone"
    inputs: []
    outputs: [{ name: "Audio Out" }]
    
  Components.insert
    name: "Speaker"
    inputs: [{ name: "Audio In" }]
    outputs: []
    
  Components.insert
    name: "Delay"
    inputs: [{ name: "Audio In" }, { name: "Delay time", param: "delayTime", min: 0, max: 10, value: 0 }]
    outputs: [{ name: "Audio Out" }]

  Components.insert
    name: "Gain"
    inputs: [{ name: "Audio In" }, { name: "Gain", param: "gain", min: 0, max: 10, value: 1 }]
    outputs: [{ name: "Audio Out" }]
  
  Components.insert
    name: "Oscillator"
    inputs: [
      { name: "Frequency", param: "frequency", min: 0, max: 2000, value: 440 },
      { name: "Detune", param: "detune", min: -1200, max: 1200, value: 0 }
    ]
    outputs: [{ name: "Audio Out" }]
    type: 0

  Components.insert
    name: "Biquad Filter"
    inputs: [
      { name: "Audio In" },
      { name: "Frequency", param: "frequency", min: 0, max: 2000, value: 350 },
      { name: "Detune", param: "detune", min: -1200, max: 1200, value: 0 },
      { name: "Q", param: "Q", min: 0, max: 1000, value: 1 },
      { name: "Gain", param: "gain", min: -40, max: 40, value: 0 }
    ]
    outputs: [{ name: "Audio Out" }]
    type: 0
    
  Components.insert
    name: "Convolver"
    inputs: [{ name: "Audio In" }]
    outputs: [{ name: "Audio Out" }]