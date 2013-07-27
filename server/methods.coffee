Meteor.methods
  deleteBox: (id) ->
    Connections.remove {inputBoxId: id}
    Connections.remove {outputBoxId: id}
    Boxes.remove {_id: id}
  deleteConn: (id) ->
    Connections.remove {_id: id}
