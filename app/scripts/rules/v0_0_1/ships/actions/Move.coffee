define(["underscore", "backbone", "lib/2D/TransformBearings", "lib/turncoat/RuleBookEntry", "lib/turncoat/Action"], (_, Backbone, TransformBearings, RuleBookEntry, Action)->

  move = new RuleBookEntry()
  move.getActionRules = (game)->
    if !game? then throw new Error('A game must be supplied to retrieve rules')

    calculateTurnActionRequired:(asset, moveType, turn, x, y)->
      currentPos = asset.get("position")
      rotateX = currentPos.get("x")
      rotateY = currentPos.get("y")
      if turn.get("beforeMove")
        v =TransformBearings.bearingAndDistanceToVector(currentPos.get("bearing"),turn.get("beforeMove"))
        rotateX += v.x
        rotateY += v.y
      bd = TransformBearings.vectorToBearingAndDistance(
          x:x-rotateX
          y:y-rotateY
      )
      idealRotation = TransformBearings.rotationBetweenBearings(currentPos.get("bearing"),bd.bearing)
      rotation = Math.min(idealRotation, turn.get("maxRotation"))
      rotation = Math.max(rotation, -turn.get("maxRotation"))
      shortfall = idealRotation - rotation
      action:new Action(
          asset:asset.get("id")
          rule:"ships.actions.move"
          move:moveType
          turn:turn.get("name")
          rotation:rotation
        )
      shortfall:shortfall


    calculateMoveRemaining:(asset, moveType)->

    resolveAction:(action, resolveNonDeterministic)->
      action.reset()
      assets = game.searchGameStateModels((gsm)->
        gsm?.get? and gsm.get("id") is action.get("asset")
      )
      if assets.length>1 then throw new Error("Duplicate asset id's found in game, this is not valid")
      if assets.length is 0 then throw new Error("Asset not found")
      asset = assets[0]
      move = asset.get("actions").findWhere(name:"move").get("types").findWhere(name:action.get("move"))
      if action.get("turn")?
        turn = move.get("turns").findWhere(name:action.get("turn"))
        pos = asset.get("position")
        x = pos.get("x")
        y = pos.get("y")
        bearing = pos.get("bearing")
        if turn.get("beforeMove")?
          v = TransformBearings.bearingAndDistanceToVector(bearing, turn.get("beforeMove"))
          x+=v.x
          y+=v.y

        bearing = TransformBearings.rotateBearing(bearing, action.get("rotation"))

        if turn.get("afterMove")?
          v = TransformBearings.bearingAndDistanceToVector(bearing, turn.get("afterMove"))
          x+=v.x
          y+=v.y

        action.get("events").push()


  move.getEventRules=(game)->




  move

)