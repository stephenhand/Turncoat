define(["underscore", "backbone", "lib/2D/TransformBearings", "lib/turncoat/RuleBookEntry", "lib/turncoat/Action", "lib/turncoat/Event"], (_, Backbone, TransformBearings, RuleBookEntry, Action, Event)->

  move = new RuleBookEntry()
  move.getActionRules = (game)->
    if !game? then throw new Error('A game must be supplied to retrieve rules')

    calculateManeuverRequired:(asset, moveType, maneuver, x, y)->
      currentPos = asset.get("position")
      rotateX = currentPos.get("x")
      rotateY = currentPos.get("y")
      for step in maneuver.get("sequence").models
        if step.get("type") is "move"
          v =TransformBearings.bearingAndDistanceToVector(TransformBearings.rotateBearing(currentPos.get("bearing"),(step.get("direction") ? 0)),step.evaluate("distance")||0)
          rotateX += v.x
          rotateY += v.y
        else if step.get("type") is "rotate"
          bd = TransformBearings.vectorToBearingAndDistance(
            x:x-rotateX
            y:y-rotateY
          )
          idealRotation = TransformBearings.rotationBetweenBearings(currentPos.get("bearing"),bd.bearing)
          rotation = Math.min(idealRotation, step.get("maxRotation"))
          rotation = Math.max(rotation, -step.get("maxRotation"))
          shortfall = idealRotation - rotation
          ret =
            action:new Action(
                asset:asset.get("id")
                rule:"ships.actions.move"
                move:moveType
                maneuver:maneuver.get("name")
              )
            shortfall:shortfall
          ret.action.set(step.get("rotationAttribute"), rotation)
          return ret


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
      pos = asset.get("position")
      x = pos.get("x")
      y = pos.get("y")
      bearing = pos.get("bearing")
      if action.get("maneuver")?
        waypoints = new Backbone.Collection([])
        maneuver = move.get("maneuvers").findWhere(name:action.get("maneuver"))

        for step in maneuver.get("sequence").models
          switch step.get("type")
            when "move"
              v = TransformBearings.bearingAndDistanceToVector(TransformBearings.rotateBearing(bearing, (step.get("direction") ? 0)), step.evaluate("distance"))
              x+=v.x
              y+=v.y
              waypoints.push(
                x:x
                y:y
              )
            when "rotate"
              bearing = TransformBearings.rotateBearing(bearing, action.get(step.get("rotationAttribute")))

        action.get("events").push(new Event(
          rule:"ships.actions.move"
          name:"changePosition"
          position:new Backbone.Model(
            x:x
            y:y
            bearing:bearing
          )
          waypoints:waypoints
        ))
      else
        v = TransformBearings.bearingAndDistanceToVector(TransformBearings.rotateBearing(bearing, (action.get("direction") ? 0)), action.get("distance"))
        move.get("distance")



  move.getEventRules=(game)->




  move

)