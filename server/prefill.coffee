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
    inputs: [{ name: "Audio In" }, { name: "Delay time" }]
    outputs: [{ name: "Audio Out" }]