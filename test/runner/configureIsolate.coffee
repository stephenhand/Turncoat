define(["isolate","isolateHelper", "uuid"], ( Isolate, Helper, UUID)->
  class UniquelyIdentifiable
    constructor:()->
      hashVal = UUID()
      hashProp = UUID()
      @[hashProp]=hashVal

      @__origToString = @toString()
      @toString=()->
        @[hashProp]




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
        mockJQueryObj.on=JsMockito.mockFunction()
        window.mockLibrary[requestingModulePath].jqueryObjects.methodResults ?= []
        window.mockLibrary[requestingModulePath].jqueryObjects.methodResults.parent = mockJQueryObj
        mockJQueryObj
    )
    JsMockito.when(jqm.on)(JsHamcrest.Matchers.anything(), JsHamcrest.Matchers.anything()).then(
      (eventName, cb)->
        window.mockLibrary[requestingModulePath].jqueryObjects.methodCallbacks ?= []
        window.mockLibrary[requestingModulePath].jqueryObjects.methodCallbacks.on ?= []
        window.mockLibrary[requestingModulePath].jqueryObjects.methodCallbacks.on[eventName]= cb
        @
    )


  Isolate.mapAsFactory("jquery", (actual, modulePath, requestingModulePath)->
    window.mockLibrary[requestingModulePath]?=[]
    window.mockLibrary[requestingModulePath]["jqueryObjects"]={
      getSelectorResult:(selector, context)->
        if selector is window then selector = "__WINDOW_SELECTOR_PLACEHOLDER"
        if context is window then context = "__WINDOW_CONTEXT_PLACEHOLDER"
        if (context?)
          @[selector][context]
        else
          @[selector]
    }
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->

      mockJQuery = JsMockito.mockFunction()
      imp = (selector, context)=>

        #Without these 2 lines $(window) or $(foo, window) cause circular references when put into window.mocklibrary, which will then leak memory
        #use 'getSelectorResult passing in window where appropriate will yield the correct object
        if selector is window then selector="__WINDOW_SELECTOR_PLACEHOLDER"
        if context is window then context="__WINDOW_CONTEXT_PLACEHOLDER"

        if typeof selector is "object" then _.extend(selector, new UniquelyIdentifiable())
        if typeof context is "object" then _.extend(selector, new UniquelyIdentifiable())
        mockJQueryObj = JsMockito.mock(actual)
        mockJQueryObj.jqm=JsMockito.mockFunction()
        mockJQueryObj.jqmShow=JsMockito.mockFunction()
        mockJQueryObj.jqmHide=JsMockito.mockFunction()
        mockJQueryObj.jqmAddTrigger=JsMockito.mockFunction()
        mockJQueryObj.jqmAddClose=JsMockito.mockFunction()
        mockJQueryObj.on=JsMockito.mockFunction()
        setMocks(mockJQueryObj,actual,requestingModulePath)
        if context?
          window.mockLibrary[requestingModulePath].jqueryObjects[selector][context] = mockJQueryObj
        else
          window.mockLibrary[requestingModulePath].jqueryObjects[selector] = mockJQueryObj
        mockJQueryObj
      JsMockito.when(mockJQuery)(JsHamcrest.Matchers.anything()).then(
        (selector)=>
          imp(selector)
      )
      JsMockito.when(mockJQuery)(JsHamcrest.Matchers.anything(),JsHamcrest.Matchers.anything()).then(
        (selector, context)=>
          imp(selector, context)

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


  null
)