define(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapType('object',Isolate.mapAsFactory((actual, modulePath, requestingModulePath)->
      actual
    )
  )
  Isolate.mapType('function',Isolate.mapAsFactory((actual, modulePath, requestingModulePath)->
      actual
    )
  )

  setMocks = (jqm,actual,requestingModulePath)->
    JsMockito.when(jqm.parent)().then(
      ()->
        mockJQueryObj = JsMockito.mock(actual)
        mockJQueryObj.jqm=JsMockito.mockFunction()
        mockJQueryObj.jqmShow=JsMockito.mockFunction()
        mockJQueryObj.jqmHide=JsMockito.mockFunction()
        mockJQueryObj.jqmAddTrigger=JsMockito.mockFunction()
        mockJQueryObj.jqmAddClose=JsMockito.mockFunction()
        window.mockLibrary[requestingModulePath].jqueryObjects.methodResults ?= []
        window.mockLibrary[requestingModulePath].jqueryObjects.methodResults.parent = mockJQueryObj
        mockJQueryObj
    )

  Isolate.mapAsFactory("jquery", (actual, modulePath, requestingModulePath)->
    window.mockLibrary[requestingModulePath]["jqueryObjects"]={}
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->

      mockJQuery = JsMockito.mockFunction()
      JsMockito.when(mockJQuery)(JsHamcrest.Matchers.anything()).then(
        (selector)=>
          mockJQueryObj = JsMockito.mock(actual)
          mockJQueryObj.jqm=JsMockito.mockFunction()
          mockJQueryObj.jqmShow=JsMockito.mockFunction()
          mockJQueryObj.jqmHide=JsMockito.mockFunction()
          mockJQueryObj.jqmAddTrigger=JsMockito.mockFunction()
          mockJQueryObj.jqmAddClose=JsMockito.mockFunction()
          setMocks(mockJQueryObj,actual,requestingModulePath)
          window.mockLibrary[requestingModulePath].jqueryObjects[selector] = mockJQueryObj
          mockJQueryObj
      )
      JsMockito.when(mockJQuery)(JsHamcrest.Matchers.anything(),JsHamcrest.Matchers.anything()).then(
        (selector, context)=>
          mockJQueryObj = JsMockito.mock(actual)
          mockJQueryObj.jqm=JsMockito.mockFunction()
          mockJQueryObj.jqmShow=JsMockito.mockFunction()
          mockJQueryObj.jqmHide=JsMockito.mockFunction()
          mockJQueryObj.jqmAddTrigger=JsMockito.mockFunction()
          mockJQueryObj.jqmAddClose=JsMockito.mockFunction()
          setMocks(mockJQueryObj,actual,requestingModulePath)
          if context?
            window.mockLibrary[requestingModulePath].jqueryObjects[selector][context] = mockJQueryObj
          else
            window.mockLibrary[requestingModulePath].jqueryObjects[selector] = mockJQueryObj
          mockJQueryObj
      )
      mockJQuery

    )
  )



  Isolate.mapAsFactory("lib/turncoat/Factory", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
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
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
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
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      mockFleetAsset = actual
      window.mockLibrary[requestingModulePath]["state/FleetAsset"]=mockFleetAsset
      mockFleetAsset
    )
  )

  Isolate.mapAsFactory("UI/BaseViewModelCollection", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      mockConstructedBVMC = {}
      switch requestingModulePath

        when "UI/PlayAreaView"


        else
          mockBaseViewModelCollection = actual
      mockBaseViewModelCollection
    )
  )


  Isolate.mapAsFactory("UI/ManOWarTableTopView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      switch requestingModulePath

        when "App"
          mockManOWarTableTopView = ()->
            mmttv = JsMockito.mock(actual)
            mmttv.mockId = "MOCK_MANOWARTABLETOPVIEW"
            mmttv
        else
          mockManOWarTableTopView = actual

      mockManOWarTableTopView
    )
  )
  null
)