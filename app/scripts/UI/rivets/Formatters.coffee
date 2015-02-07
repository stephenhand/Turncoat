define(["underscore", "sprintf", "rivets", "lib/2D/TransformBearings"], (_, sprintf, Rivets, TransformBearings)->
  #alias for use in calc functions
  bearings = TransformBearings
  Formatters =
    rotateCss:(input)->
      "rotate("+input+"deg)"
    toggle:(input, trueVal, falseVal)->
      if (input) then trueVal else falseVal
    sprintf:(input, mask)->
      sprintf(mask, input)
    multiplier:(input, multiplier, mask)->
      val = input * multiplier
      if isNaN(val) then val =input
      if (mask?) then val = sprintf(mask, val)
      val
    centroid:(input, posAtt, dimAtt)->
      pos = parseFloat(input.get(posAtt))
      posAdjust = parseFloat(input.get(dimAtt))/2
      if (isNaN(pos)) then throw new Error("Cannot set centroid to "+posAtt+" because "+posAtt+" is "+input.get(posAtt))
      if (isNaN(posAdjust)) then throw new Error("Cannot set centroid to  "+posAtt+" attribute because  "+dimAtt+" is "+input.get(dimAtt))
      return pos-posAdjust

    pathDefinitionFromActions:(actions)->
      pathSpec = "m 0 0"
      if actions?
        if not (actions instanceof Backbone.Collection) then actions = new Backbone.Collection([actions])

        currentPosition = null
        for action in actions.models when action.get("events")
          for event in action.get("events").models when event.get("rule") is "ships.events.changePosition"
            if !currentPosition?
              currentPosition=event.get("waypoints")?.at(0)
              if currentPosition?
                pathSpec = sprintf("m %s %s", currentPosition.get("x"), currentPosition.get("y"))
              else
                return pathSpec
            if !event.get("position").get("x")? or !event.get("position").get("y")? or !event.get("position").get("bearing")? then throw new Error("Invalid position data in changePosition event: "+JSON.stringify(event))
            dist = TransformBearings.vectorToBearingAndDistance(
                x:event.get("position").get("x")-currentPosition.get("x")
                y:event.get("position").get("y")-currentPosition.get("y")
            ).distance/2.5
            cubicControl1 = TransformBearings.bearingAndDistanceToVector(currentPosition.get("bearing"), dist)
            cubicControl2 = TransformBearings.bearingAndDistanceToVector(TransformBearings.rotateBearing(event.get("position").get("bearing"), 180), dist)
            pathSpec += sprintf(" c %s %s, %s %s, %s %s",
              cubicControl1.x, cubicControl1.y,
              (event.get("position").get("x")+cubicControl2.x) - currentPosition.get("x"), (event.get("position").get("y")+cubicControl2.y) - currentPosition.get("y"),
              event.get("position").get("x")-currentPosition.get("x"),event.get("position").get("y")-currentPosition.get("y")
            )
            currentPosition = event.get("position")
      pathSpec

    calc:(input, mask)->
      if !mask? then return input
      vals = []
      if typeof input is "number"
        vals = [input]
      else
        for attr,idx in arguments when idx>1
          adapter = Rivets.adapters[Rivets.config.rootInterface]
          sectionStart = 0
          sectionEnd = 0
          val = input
          currentChar = 1
          while currentChar
            currentChar = attr.charAt(sectionEnd)
            if !currentChar or Rivets.adapters[currentChar]
              if sectionStart<sectionEnd
                val = adapter.read(val, attr.substring(sectionStart, sectionEnd))
              adapter = Rivets.adapters[currentChar]
              sectionStart = sectionEnd+1
            sectionEnd++

          if typeof val is "number" then vals.push(val) else throw new Error("All inputs to calc formatter must be numeric.")

      vals.unshift(mask)
      eval(sprintf.apply(null, vals))

  _.extend(Rivets.formatters, Formatters)
  Formatters
)