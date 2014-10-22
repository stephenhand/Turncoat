define(["fmod"], (fmod)->
  DEGREES_TO_RADIANS = Math.PI / 180

  bearingAndDistanceToVector=(bearing, distance)->
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


  vectorToBearingAndDistance=(vector)->
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

    bearing : baseBearing + (Math.atan(opposite/adjacent)/DEGREES_TO_RADIANS)
    distance : Math.sqrt((opposite*opposite)+(adjacent*adjacent))

  rotateBearing=(start, rotation)->
    if (typeof start isnt "number") || (typeof rotation isnt "number") then throw Error("Start bearing and rotation values must be numeric")
    fmod(start+rotation, 360)

  rotationBetweenBearings=(start, end)->
    if (typeof start isnt "number") || (typeof end isnt "number") then throw Error("Start and end bearings must be numeric")
    val = fmod(end-start, 360)
    if val>180 then val-=360
    val

  intersectionVectorOf2PointsWithBearings=(pointA, pointB)->
    if !pointA? or !pointB? then throw new Error("2 points are required")
    if !pointA.x? or !pointA.y? or !pointB.x? or !pointB.y? then throw new Error("x and y coordinates are required on both points")
    if !pointA.bearing? or !pointB.bearing? then throw new Error("Bearings are required on both points")
    betweenAB = vectorToBearingAndDistance(
      x:pointB.x - pointA.x
      y:pointB.y - pointA.y
    )
    diff = Math.abs(rotationBetweenBearings(pointA.bearing,pointB.bearing))
    if diff is 0 then throw new Error('Parallel paths will not cross')
    if diff is 180
      if betweenAB.bearing isnt pointA.bearing
        throw new Error('2 paths that pass in opposite directions will not cross')
      else
        x:(pointB.x - pointA.x)/2
        y:(pointB.y - pointA.y)/2
    else
      sideC = betweenAB.distance
      angleA = Math.abs(rotationBetweenBearings(pointA.bearing, betweenAB.bearing))
      angleB = Math.abs(rotationBetweenBearings(pointB.bearing, rotateBearing(betweenAB.bearing, 180)))
      vectorBearing = pointA.bearing
      if (angleA+angleB)>180
        angleA = Math.abs(rotationBetweenBearings(pointA.bearing, rotateBearing(betweenAB.bearing, 180)))
        angleB = Math.abs(rotationBetweenBearings(pointB.bearing, betweenAB.bearing))
        vectorBearing = rotateBearing(pointA.bearing, 180)
      angleC = 180 - angleA - angleB
      sideB = (sideC/Math.sin(angleC*DEGREES_TO_RADIANS))*Math.sin(angleB*DEGREES_TO_RADIANS)
      bearingAndDistanceToVector(vectorBearing, sideB)


  bearingAndDistanceToVector:bearingAndDistanceToVector
  vectorToBearingAndDistance:vectorToBearingAndDistance
  rotateBearing:rotateBearing
  rotationBetweenBearings:rotationBetweenBearings
  intersectionVectorOf2PointsWithBearings:intersectionVectorOf2PointsWithBearings
)