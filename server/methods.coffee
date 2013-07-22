Meteor.methods
  deleteBox: (id) ->
    Connections.remove {sourceBoxId: id}
    Connections.remove {targetBoxId: id}
    Boxes.remove {_id: id}
  deleteConn: (id) ->
    Connections.remove {_id: id}
