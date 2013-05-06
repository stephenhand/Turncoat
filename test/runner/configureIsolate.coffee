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

  Isolate.mapAsFactory("jquery", (actual, modulePath, requestingModulePath)->
    if (!window.mockLibrary[requestingModulePath])
      window.mockLibrary[requestingModulePath] = {}

    mockJQuery = JsMockito.mockFunction()
    JsMockito.when(mockJQuery)(JsHamcrest.Matchers.anything()).then(
      (selector, context)->
        mockJQueryObj = JsMockito.mock(actual)
        window.mockLibrary[requestingModulePath].jqueryObjects[selector] = mockJQueryObj
        mockJQueryObj
    )
    JsMockito.when(mockJQuery)(JsHamcrest.Matchers.anything(),JsHamcrest.Matchers.anything()).then(
      (selector)->
        mockJQueryObj = JsMockito.mock(actual)
        if context?
          window.mockLibrary[requestingModulePath].jqueryObjects[selector][context] = mockJQueryObj
        else
          window.mockLibrary[requestingModulePath].jqueryObjects[selector] = mockJQueryObj
        mockJQueryObj
    )
    #_.extend(mockJQuery,mockJQueryObj)
    switch requestingModulePath
      when "UI/BaseView"
        mockJQuery


    window.mockLibrary[requestingModulePath]["jquery"]=mockJQuery
    window.mockLibrary[requestingModulePath]["jqueryObjects"]={}
    mockJQuery
  )
  #Isolate.mapAsFactory("uuid", (actual, modulePath, requestingModulePath)->
  #  if (!window.mockLibrary[requestingModulePath])
  #    window.mockLibrary[requestingModulePath] = {}
  #  actual
  #)
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
          bind:JsMockito.mockFunction()
        JsMockito.when(stubRivets.bind)(JsHamcrest.Matchers.anything(),JsHamcrest.Matchers.anything()).then(
          (selector, model)->
            id:"MOCK_RIVETS_VIEW"
            selector:selector
        )
      when "UI/RivetsExtensions"
        stubRivets =
          binders:{}
          formatters:{}

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


    mockGameStateModel.fromString = JsMockito.mockFunction()
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
          buildStateMarshaller:JsMockito.mockFunction()
        mockMarshaller = JsMockito.mockFunction()
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

  Isolate.mapAsFactory("state/FleetAsset", (actual, modulePath, requestingModulePath)->
    if (!window.mockLibrary[requestingModulePath])
      window.mockLibrary[requestingModulePath] = {}
    mockConstructedFA = JsMockito.mock(actual)
    switch requestingModulePath

      when "UI/PlayAreaViexw"
        mockFleetAsset = ()->
          mockConstructedFA
      else
        mockFleetAsset = actual
    window.mockLibrary[requestingModulePath]["state/FleetAsset"]=mockFleetAsset
    mockFleetAsset
  )

  Isolate.mapAsFactory("UI/BaseViewModelCollection", (actual, modulePath, requestingModulePath)->
    if (!window.mockLibrary[requestingModulePath])
      window.mockLibrary[requestingModulePath] = {}
    mockConstructedBVMC = {}
    switch requestingModulePath

      when "UI/PlayAreaView"
        mockBaseViewModelCollection = (data)->
          mockConstructedBVMC = new Backbone.Collection(data)
          mockConstructedBVMC.watch = JsMockito.mockFunction()
          JsMockito.when(mockConstructedBVMC.watch)(JsHamcrest.Matchers.anything()).then((collections)->
            mockConstructedBVMC.watchedCollections = collections
          )
          mockConstructedBVMC

      else
        mockBaseViewModelCollection = actual
    window.mockLibrary[requestingModulePath]["UI/PlayAreaView"]=mockBaseViewModelCollection
    mockBaseViewModelCollection
  )

  Isolate.mapAsFactory("UI/FleetAsset2DModel", (actual, modulePath, requestingModulePath)->
    if (!window.mockLibrary[requestingModulePath])
      window.mockLibrary[requestingModulePath] = {}
    mockConstructedFA2DM = JsMockito.mock(actual)
    JsMockito.when(mockConstructedFA2DM.get)(JsHamcrest.Matchers.anything()).then(
      (att)->
        switch att
          when "uuid" then mockConstructedFA2DM.uuid
    )
    switch requestingModulePath
      when "UI/PlayAreaView"
        mockFleetAsset2DModel = (option)->
          mockConstructedFA2DM.uuid = option?.model?.get("uuid")
          mockConstructedFA2DM

      else
        mockFleetAsset2DModel = actual
    window.mockLibrary[requestingModulePath]["UI/PlayAreaView"]=mockFleetAsset2DModel
    mockFleetAsset2DModel
  )

  Isolate.mapAsFactory("UI/PlayAreaView", (actual, modulePath, requestingModulePath)->
    if (!window.mockLibrary[requestingModulePath])
      window.mockLibrary[requestingModulePath] = {}
    switch requestingModulePath

      when "UI/ManOWarTableTopView"
        mockPlayAreaView = ()->
          mockId:"MOCK_PLAYAREAVIEW"

      else
        mockPlayAreaView = actual


    window.mockLibrary[requestingModulePath]["UI/PlayAreaView"]=mockPlayAreaView
    mockPlayAreaView
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