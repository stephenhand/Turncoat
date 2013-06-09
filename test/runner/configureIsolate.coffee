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

  mapAndRecord = (actual, path, requestingModulePath, mapFunc)->
    if (!window.mockLibrary[requestingModulePath])
      window.mockLibrary[requestingModulePath] = {}
    mock = mapFunc()
    window.mockLibrary[requestingModulePath][path]=mock
    mock

  Isolate.mapAsFactory("jquery", (actual, modulePath, requestingModulePath)->
    window.mockLibrary[requestingModulePath]["jqueryObjects"]={}
    mapAndRecord(actual, modulePath, requestingModulePath, ()->

      mockJQuery = JsMockito.mockFunction()
      JsMockito.when(mockJQuery)(JsHamcrest.Matchers.anything()).then(
        (selector)->
          mockJQueryObj = JsMockito.mock(actual)
          window.mockLibrary[requestingModulePath].jqueryObjects[selector] = mockJQueryObj
          mockJQueryObj
      )
      JsMockito.when(mockJQuery)(JsHamcrest.Matchers.anything(),JsHamcrest.Matchers.anything()).then(
        (selector, context)->
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
    )
  )
  #Isolate.mapAsFactory("id", (actual, modulePath, requestingModulePath)->
  #  if (!window.mockLibrary[requestingModulePath])
  #    window.mockLibrary[requestingModulePath] = {}
  #  actual
  #)
  Isolate.mapAsFactory("rivets", (actual, modulePath, requestingModulePath)->
    mapAndRecord(actual, modulePath, requestingModulePath, ()->
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
      stubRivets
    )
  )

  Isolate.mapAsFactory("lib/turncoat/Game", (actual, modulePath, requestingModulePath)->
    mapAndRecord(actual, modulePath, requestingModulePath, ()->
      mockConstructedGame =
        loadState:(state)->
      switch requestingModulePath
        when "App"
          mockGame = ()->
            mockConstructedGame
      mockGame
    )
  )


  Isolate.mapAsFactory("lib/turncoat/GameStateModel", (actual, modulePath, requestingModulePath)->
    mapAndRecord(actual, modulePath, requestingModulePath, ()->
      mockConstructedGameStateModel = {}

      switch requestingModulePath
        when "lib/turncoat/Game"
          mockGameStateModel = ()->
            mockConstructedGameStateModel
        else
          mockGameStateModel = actual


      mockGameStateModel.fromString = JsMockito.mockFunction()
      mockGameStateModel
    )
  )

  Isolate.mapAsFactory("lib/2D/PolygonTools", (actual, modulePath, requestingModulePath)->
    mapAndRecord(actual, modulePath, requestingModulePath, ()->
      mockPolygonTools

      switch requestingModulePath

        when "App","UI/BaseView"
          mockPolygonTools =
            pointInPoly:(poly,x,y)->
      mockPolygonTools
    )
  )

  Isolate.mapAsFactory("lib/turncoat/Factory", (actual, modulePath, requestingModulePath)->
    mapAndRecord(actual, modulePath, requestingModulePath, ()->
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
      mockFactory
    )
  )


  Isolate.mapAsFactory("lib/turncoat/StateRegistry", (actual, modulePath, requestingModulePath)->
    mapAndRecord(actual, modulePath, requestingModulePath, ()->
      switch requestingModulePath
        when "lib/marshallers/JSONMarshaller"
          mockStateRegistry =
            reverse:[]
        else
          mockStateRegistry = actual
      mockStateRegistry
    )
  )

  Isolate.mapAsFactory("state/FleetAsset", (actual, modulePath, requestingModulePath)->
    mapAndRecord(actual, modulePath, requestingModulePath, ()->
      mockFleetAsset = actual
      window.mockLibrary[requestingModulePath]["state/FleetAsset"]=mockFleetAsset
      mockFleetAsset
    )
  )

  Isolate.mapAsFactory("UI/BaseViewModelCollection", (actual, modulePath, requestingModulePath)->
    mapAndRecord(actual, modulePath, requestingModulePath, ()->
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
      mockBaseViewModelCollection
    )
  )

  Isolate.mapAsFactory("UI/FleetAsset2DViewModel", (actual, modulePath, requestingModulePath)->
    mapAndRecord(actual, modulePath, requestingModulePath, ()->

      switch requestingModulePath
        when "UI/PlayAreaView"
          mockFleetAsset2DModel = (option)->
            mockConstructedFA2DM = JsMockito.mock(actual)
            JsMockito.when(mockConstructedFA2DM.get)(JsHamcrest.Matchers.anything()).then(
              (att)->
                switch(att)
                  when "modelId"
                    mockConstructedFA2DM.modelId
            )
            mockConstructedFA2DM.modelId = option?.model.id
            mockConstructedFA2DM.cid=option?.model.id
            mockConstructedFA2DM
        else
          mockFleetAsset2DModel = actual
      mockFleetAsset2DModel
    )
  )

  Isolate.mapAsFactory("UI/ManOWarTableTopView", (actual, modulePath, requestingModulePath)->
    mapAndRecord(actual, modulePath, requestingModulePath, ()->
      switch requestingModulePath

        when "App"
          mockManOWarTableTopView = ()->
            JsMockito.mock(actual)
        else
          mockManOWarTableTopView = actual

      mockManOWarTableTopView
    )
  )

  Isolate.mapAsFactory("UI/PlayAreaView", (actual, modulePath, requestingModulePath)->
    mapAndRecord(actual, modulePath, requestingModulePath, ()->
      switch requestingModulePath

        when "UI/ManOWarTableTopView"
          mockPlayAreaView = ()->
            mockId:"MOCK_PLAYAREAVIEW"

        else
          mockPlayAreaView = actual

      mockPlayAreaView
    )
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