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
        _when(stubRivets.bind)(JsHamcrest.Matchers.anything(),JsHamcrest.Matchers.anything()).then(
          (selector, model)->
            id:"MOCK_RIVETS_VIEW"
            selector:selector
        )

    window.mockLibrary[requestingModulePath]["rivets"]=stubRivets
    stubRivets
  )

  Isolate.mapAsFactory("lib/turncoat/Game", (actual, modulePath, requestingModulePath)->
    if (!window.mockLibrary[requestingModulePath])
      window.mockLibrary[requestingModulePath] = {}
    mockConstructedGame =
      loadState:(state)->

    switch requestingModulePath

      when "App"
        mockGame = ()->
          mockConstructedGame


    window.mockLibrary[requestingModulePath]["lib/turncoat/Game"]=mockGame
    mockGame
  )


  Isolate.mapAsFactory("lib/turncoat/GameStateModel", (actual, modulePath, requestingModulePath)->
    if (!window.mockLibrary[requestingModulePath])
      window.mockLibrary[requestingModulePath] = {}
    mockConstructedGameStateModel = {}

    switch requestingModulePath
      when "lib/turncoat/Game"
        mockGameStateModel = ()->
          mockConstructedGameStateModel
      else
        mockGameStateModel = actual


    mockGameStateModel.fromString = mockFunction()
    window.mockLibrary[requestingModulePath]["lib/turncoat/GameStateModel"]=mockGameStateModel
    mockGameStateModel
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

  Isolate.mapAsFactory("lib/turncoat/Factory", (actual, modulePath, requestingModulePath)->
    if (!window.mockLibrary[requestingModulePath])
      window.mockLibrary[requestingModulePath] = {}
    switch requestingModulePath

      when "lib/turncoat/GameStateModel"
        mockFactory =
          buildStateMarshaller:mockFunction()
        mockMarshaller = mockFunction()
        JsMockito.when(mockMarshaller)(JsHamcrest.Matchers.anything()).then(
          ()->
            "MOCK_MARSHALLER_OUTPUT"
        )
        JsMockito.when(mockFactory.buildStateMarshaller)().then(
          ()->
            marshalState:mockMarshaller
        )
      else
        mockFactory = actual


    window.mockLibrary[requestingModulePath]["lib/turncoat/Factory"]=mockFactory
    mockFactory
  )


  Isolate.mapAsFactory("lib/turncoat/StateRegistry", (actual, modulePath, requestingModulePath)->
    if (!window.mockLibrary[requestingModulePath])
      window.mockLibrary[requestingModulePath] = {}
    switch requestingModulePath

      when "lib/marshallers/JSONMarshaller"
        mockStateRegistry =
          reverse:[]

      else
        mockStateRegistry = actual


    window.mockLibrary[requestingModulePath]["lib/turncoat/StateRegistry"]=mockStateRegistry
    mockStateRegistry
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