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

    calculateStraightLineMoveRequired:(asset, moveType, x, y)->
      moveDefinition = asset.get("actions").findWhere(name:"move").get("types").findWhere(name:moveType)
      if !moveDefinition? then throw new Error("Specified move type not fouind for this asset")
      position = asset.get("position")
      if !position.get("x")? or !position.get("y")? or !position.get("bearing")? then throw new Error("Incomplete position information for asset.")
      minBearing = TransformBearings.rotateBearing(position.get("bearing"), moveDefinition.get("minDirection") ? 0)
      maxBearing = TransformBearings.rotateBearing(position.get("bearing"), moveDefinition.get("maxDirection") ? 0)
      maxDistance = @calculateMoveRemaining(asset, moveType)
      targetBD = TransformBearings.vectorToBearingAndDistance(
        x:x-position.get("x")
        y:y-position.get("y")
      )

      if TransformBearings.rotationBetweenBearings(targetBD.bearing, minBearing, direction:TransformBearings.CLOCKWISE)>TransformBearings.rotationBetweenBearings(targetBD.bearing, maxBearing, direction:TransformBearings.CLOCKWISE)
        return new Action(
          asset:asset.get("id")
          rule:"ships.actions.move"
          move:moveType
          distance:Math.min(targetBD.distance, maxDistance)
          direction:TransformBearings.rotateBearing(targetBD.bearing,-position.get("bearing"))
        )
      else if TransformBearings.rotationBetweenBearings(minBearing, maxBearing, direction:TransformBearings.CLOCKWISE)>180 ||
        (
            TransformBearings.rotationBetweenBearings(targetBD.bearing, TransformBearings.rotateBearing(minBearing, -90),direction:TransformBearings.CLOCKWISE) >
            TransformBearings.rotationBetweenBearings(targetBD.bearing, TransformBearings.rotateBearing(maxBearing, 90), direction:TransformBearings.CLOCKWISE)
        )
        referenceBearing = null
        if Math.abs(TransformBearings.rotationBetweenBearings(targetBD.bearing, minBearing))<Math.abs(TransformBearings.rotationBetweenBearings(targetBD.bearing, maxBearing))
          referenceBearing=minBearing
        else
          referenceBearing=maxBearing
        closestBD = TransformBearings.vectorToBearingAndDistance(
          TransformBearings.intersectionVectorOf2PointsWithBearings(
            x:x
            y:y
            bearing:referenceBearing
          ,
            x:position.get("x")
            y:position.get("y")
            bearing:TransformBearings.rotateBearing(referenceBearing, 90)
          )
        )

        return new Action(
          asset:asset.get("id")
          rule:"ships.actions.move"
          move:moveType
          distance:Math.min(closestBD.distance, maxDistance)
          direction:TransformBearings.rotateBearing(TransformBearings.rotateBearing(closestBD.bearing,180),-position.get("bearing"))
        )

      else
        return new Action(
          asset:asset.get("id")
          rule:"ships.actions.move"
          move:moveType
          distance:0
          direction:0
        )



    calculateMoveRemaining:(asset, moveType)->
      6

    resolveAction:(action, resolveNonDeterministic)->
      action.reset()
      assets = game.searchGameStateModels((gsm)->
        gsm?.get? and gsm.get("id") is action.get("asset")
      )
      if assets.length>1 then throw new Error("Duplicate asset id's found in game, this is not valid")
      if assets.length is 0 then throw new Error("Asset not found")
      asset = assets[0]
      move = asset.get("actions").findWhere(name:"move").get("types").findWhere(name:action.get("move"))
      if !move? then throw new Error ("Specified move not found")
      pos = asset.get("position")
      x = pos.get("x")
      y = pos.get("y")
      bearing = pos.get("bearing")
      waypoints = new Backbone.Collection([pos])
      if action.get("maneuver")?
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
      else
        v = TransformBearings.bearingAndDistanceToVector(TransformBearings.rotateBearing(bearing, (action.get("direction") ? 0)), action.get("distance") ? 0)
        x+=v.x
        y+=v.y
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
      action



  move.getEventRules=(game)->




  move

)