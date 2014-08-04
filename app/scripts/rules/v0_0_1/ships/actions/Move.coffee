define(["underscore", "backbone", "lib/2D/TransformBearings", "lib/turncoat/RuleBookEntry", "lib/turncoat/Action"], (_, Backbone, TransformBearings, RuleBookEntry, Action)->

  move = new RuleBookEntry()
  move.getRule = (game)->
    if !game? then throw new Error('A game must be supplied to retrieve rules')

    calculateTurnActionRequired:(asset, moveType, turn, x, y)->
      currentPos = asset.get("position")
      bd = TransformBearings.vectorToBearingAndDistance(
          x:x-currentPos.get("x")
          y:y-currentPos.get("y")
      )
      idealRotation = TransformBearings.rotationBetweenBearings(currentPos.get("bearing"),bd.bearing)
      rotation = Math.min(idealRotation, turn.get("maxRotation"))
      rotation = Math.max(rotation, -turn.get("maxRotation"))
      shortfall = idealRotation - rotation
      action:new Action(
          asset:asset.get("id")
          type:"move"
          move:moveType
          turn:turn.get("name")
          rotation:rotation
        )
      shortfall:shortfall


    calculateMoveRemaining:(asset, moveType)->

    resolveAction:(action, resolveNonDeterministic)->



  move

)