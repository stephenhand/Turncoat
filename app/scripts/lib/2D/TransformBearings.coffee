define([], ()->
  TransformBearings =
    bearingAndDistanceToVector:(bearing, distance)->
      if bearing is 0 then return {x:0,y:-distance}
      if bearing is 90 then return {x:distance,y:0}
      if bearing is 180 then return {x:0,y:distance}
      if bearing is 270 then return {x:-distance,y:0}
      quadrant = Math.floor(bearing/4)
      triAngle = bearing%4



  TransformBearings
)