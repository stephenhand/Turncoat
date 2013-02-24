define(["isolate"], (Isolate)->
  Isolate.mapType('object',Isolate.mapAsFactory((actual, modulePath, requestingModulePath)->
      actual
    )
  )
  Isolate.mapType('function',Isolate.mapAsFactory((actual, modulePath, requestingModulePath)->
      actual
    )
  )
  window.mockLibrary = {};
  Isolate.mapAsFactory("rivets", (actual, modulePath, requestingModulePath)->
    if (!window.mockLibrary[requestingModulePath])
      window.mockLibrary[requestingModulePath] = {}

    switch requestingModulePath
      when "App"
          rivetConfig = null
          stubRivets =
            configure:(opts)=>
              rivetConfig = opts
            getRivetConfig:()->
              rivetConfig

      when "UI/BaseView"
          stubRivets =
            bind:mockFunction()

    window.mockLibrary[requestingModulePath]["rivets"]=stubRivets
    stubRivets
  )

  Isolate.mapAsFactory("lib/Game", (actual, modulePath, requestingModulePath)->
    if (!window.mockLibrary[requestingModulePath])
      window.mockLibrary[requestingModulePath] = {}
    mockConstructedGame =
      loadState:(state)->

    switch requestingModulePath

      when "App"
        mockGame = ()->
          mockConstructedGame


    window.mockLibrary[requestingModulePath]["lib/Game"]=mockGame
    mockGame
  )

  Isolate.mapAsFactory("lib/2D/PolygonTools", (actual, modulePath, requestingModulePath)->
    if (!window.mockLibrary[requestingModulePath])
      window.mockLibrary[requestingModulePath] = {}
    mockPolygonTools

    switch requestingModulePath

      when "App","UI/BaseView"
        mockPolygonTools =
          pointInPoly:(poly,x,y)->


    window.mockLibrary[requestingModulePath]["lib/2D/PolygonTools"]=mockPolygonTools
    mockPolygonTools
  )


#  Isolate.mapAsFactory("lib/2D/TransformBearings", (actual, modulePath, requestingModulePath)->
#    if (!window.mockLibrary[requestingModulePath])
#      window.mockLibrary[requestingModulePath] = {}
#    switch requestingModulePath
#      else actual
#
#    window.mockLibrary[requestingModulePath]["lib/2D/PolygonTools"]=actual
#    actual
#  )
  null
)