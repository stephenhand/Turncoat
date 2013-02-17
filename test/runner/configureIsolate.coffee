define(["isolate"], (Isolate)->
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
  null
)