define(["underscore", "backbone"], (_, Backbone)->
  class Route
    constructor:(data)->
      @parts=[]
      if (_.isString(data))
        mainPath = ""
        qstrpos = data.indexOf("?")
        if qstrpos isnt -1
          mainPath = data.substr(0,qstrpos)
          subPath = data.substr(qstrpos+1)
          @subRoutes = {}
          while true
            eqPos = subPath.indexOf("=")
            if eqPos is -1 then break
            subName = subPath.substr(0, eqPos)
            subPath = subPath.substr(eqPos+1)
            semaphore = 0
            pointer = -1
            while true
              qPoint = subPath.indexOf("?", pointer+1)
              ampPoint = subPath.indexOf("&", pointer+1)
              colonPoint = subPath.indexOf(";", pointer+1)
              if semaphore is 0 and (qPoint is -1 or ampPoint < qPoint)
                pointer = ampPoint
                break
              if qPoint isnt -1 and qPoint < colonPoint
                pointer = qPoint
                semaphore++
              else
                pointer = colonPoint
                semaphore--
              if pointer is -1 then break

            if pointer isnt -1
              @subRoutes[subName] = new Route(subPath.substr(0,pointer))
              subPath = subPath.substr(pointer+1)
            else
              @subRoutes[subName] = new Route(subPath)
              break
        else
          mainPath = data
        if mainPath.charAt(0) is "/"
          @absolute = true
          mainPath = mainPath.substr(1)
        @parts = mainPath.split("/")
        lastPart = @parts[@parts.length-1]
        while lastPart.charAt(lastPart.length-1) is ";"
          lastPart = lastPart.substr(0, lastPart.length-1)
        @parts[@parts.length-1] = lastPart






  Route.Global = new Route()
  Route
)

