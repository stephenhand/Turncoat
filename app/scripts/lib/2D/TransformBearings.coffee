define([], ()->
  DEGREES_TO_RADIANS = Math.PI / 180

  TransformBearings =
    bearingAndDistanceToVector:(bearing, distance)->
      if bearing is 0 then return {x:0,y:-distance}
      if bearing is 90 then return {x:distance,y:0}
      if bearing is 180 then return {x:0,y:distance}
      if bearing is 270 then return {x:-distance,y:0}

      quadrant = Math.ceil(bearing/90)
      triAngle = (bearing%90)

      #3rd angle in triangle
      otherAngle = 180 - (90 + triAngle)

      D = distance / Math.sin(90*DEGREES_TO_RADIANS)
      across = D * Math.sin(triAngle*DEGREES_TO_RADIANS)
      out = D * Math.sin(otherAngle*DEGREES_TO_RADIANS)

      switch quadrant
        when 1
          {x:across,y:-out}
        when 2
          {x:out,y:across}
        when 3
          {x:-across,y:out}
        when 4
          {x:-out,y:-across}




  TransformBearings
)