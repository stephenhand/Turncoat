define([], ()->
  DEGREES_TO_RADIANS = Math.PI / 180

  TransformBearings =
    bearingAndDistanceToVector:(bearing, distance)->
      if distance is 0 then return {x:0,y:0}
      if bearing is 0 then return {x:0,y:-distance}
      if bearing is 90 then return {x:distance,y:0}
      if bearing is 180 then return {x:0,y:distance}
      if bearing is 270 then return {x:-distance,y:0}

      quadrant = ((Math.floor(bearing/90))%4)+1
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
        else #can only be 4
          {x:-out,y:-across}


    vectorToBearingAndDistance:(vector)->
      if vector.x is 0 and vector.y is 0 then return {bearing:0,distance:0}
      if vector.x is 0 and vector.y<0 then return {bearing:0,distance:-vector.y}
      if vector.x>0 and vector.y is 0 then return {bearing:90,distance:vector.x}
      if vector.x is 0 and vector.y>0 then return {bearing:180,distance:vector.y}
      if vector.x<0 and vector.y is 0 then return {bearing:270,distance:-vector.x}
      baseBearing = 0
      adjacent = -vector.y
      opposite = vector.x
      if (vector.x>0 && vector.y>0)
        baseBearing = 90
        adjacent = vector.x
        opposite = vector.y
      if (vector.x<0 && vector.y>0)
        baseBearing = 180
        adjacent = vector.y
        opposite = -vector.x
      if (vector.x<0 && vector.y<0)
        baseBearing = 270
        adjacent = -vector.x
        opposite = -vector.y
      return {
        bearing : baseBearing + (Math.atan(opposite/adjacent)/DEGREES_TO_RADIANS)
        distance : Math.sqrt((opposite*opposite)+(adjacent*adjacent))
      }
  TransformBearings
)