define(["underscore", "sprintf", "rivets", "lib/2D/TransformBearings"], (_, sprintf, Rivets, TransformBearings)->

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

    pathDefFromActions:(actions)->
      if not (actions instanceof Backbone.Collection) then actions = new Backbone.Collection([actions])
      pathSpec = "m 0 0"
      currentPosition = null
      for action in actions.models when action.get("events")
        for event in action.get("events").models when event.get("name") is "changePosition"
          currentPosition?=event.get("waypoints")?.at(0)
          if !currentPosition? then return pathSpec
          centroid = TransformBearings.intersectionVectorOf2PointsWithBearings(
            x:currentPosition.get("x")
            y:currentPosition.get("y")
            bearing:TransformBearings.rotateBearing(currentPosition.get("bearing"), 90)
          ,
            x:event.get("position").get("x")
            y:event.get("position").get("y")
            bearing:TransformBearings.rotateBearing(event.get("position").get("bearing"), 90)
          )

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