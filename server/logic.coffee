Meteor.methods
  insertBox: (box) ->
    checkSynthExists box.synthId
    synthChanged box.synthId
    Boxes.insert box
  insertConn: (conn) ->
    synthChanged conn.synthId
    Connections.insert conn
  deleteBox: (id) ->
    Connections.remove {inputBoxId: id}
    Connections.remove {outputBoxId: id}
    Boxes.remove {_id: id}
  deleteConn: (id) ->
    Connections.remove {_id: id}
  renameSynth: (oldId, newId) ->
    Synths.update { synthId: oldId }, { $set: { synthId: newId } }, { multi: yes }
    Boxes.update { synthId: oldId }, { $set: { synthId: newId } }, { multi: yes }
    Connections.update { synthId: oldId }, { $set: { synthId: newId } }, { multi: yes }
  cloneSynth: (oldId, newId) ->
    Synths.find({ synthId: oldId }).forEach (obj) -> Synths.insert _.extend(_.omit(obj, "_id", "userId", "userName"), { synthId: newId })
    synthChanged newId
    Connections.find({ synthId: oldId }).forEach (obj) -> Connections.insert _.extend(_.omit(obj, "_id"), { synthId: newId })
    Boxes.find({ synthId: oldId }).forEach (obj) ->
      oldBoxId = obj._id
      newBoxId = Boxes.insert _.extend(_.omit(obj, "_id"), { synthId: newId })
      Connections.update { synthId: newId, inputBoxId: oldBoxId }, { $set: { inputBoxId: newBoxId } }, { multi: yes }
      Connections.update { synthId: newId, outputBoxId: oldBoxId }, { $set: { outputBoxId: newBoxId } }, { multi: yes }
    

checkSynthExists = (synthId) ->
  unless Synths.findOne { synthId: synthId }
    Synths.insert
      synthId: synthId
      lastChange: new Date

synthChanged = (synthId) ->
  fields = { lastChange: new Date }
  user = Meteor.user()
  if user
    fields.userId = user._id
    fields.userName = user.profile?.name
  Synths.update { synthId: synthId }, { $set: fields }