define([], ()->
  PolygonTools =
    #original javascript posted at http://www.isogenicengine.com/2010/10/13/spotlight-detecting-polygon-collision-in-javascript/
    pointInPoly:(polyCoords, pointX, pointY)->
      j = polyCoords.length - 1
      c = false
      for coord, i in polyCoords
        lastCoord = polyCoords[j]
        j=i
        if (((coord.y > pointY) != (lastCoord.y > pointY)) && (pointX < (lastCoord.x - coord.x) * (pointY - coord.y) / (lastCoord.y - coord.y) + coord.x))
          c = !c
      c

    doPolysOverlap:(poly1Coords,poly2Coords)->
      for coordToCheck in polyCoords2
        if pointInPoly(poly1Coords, coordToCheck.x, coordToCheck.y) then return true
      for coordToCheck in polyCoords1
        if pointInPoly(poly2Coords, coordToCheck.x, coordToCheck.y) then return true
      return false



  PolygonTools
)