define(["isolate","isolateHelper", "uuid"], ( Isolate, Helper, UUID)->
  class UniquelyIdentifiable
    constructor:()->
      hashVal = UUID()

      @__origToString = @toString()
      @toString=()->
        hashVal




  Isolate.mapType('object',Isolate.mapAsFactory((actual, modulePath, requestingModulePath)->
      actual
    )
  )
  Isolate.mapType('function',Isolate.mapAsFactory((actual, modulePath, requestingModulePath)->
      actual
    )
  )

  createMock = (actual,requestingModulePath)->
    jqm = JsMockito.mock(actual)
    jqm.jqm=JsMockito.mockFunction()
    jqm.jqmShow=JsMockito.mockFunction()
    jqm.jqmHide=JsMockito.mockFunction()
    jqm.jqmAddTrigger=JsMockito.mockFunction()
    jqm.jqmAddClose=JsMockito.mockFunction()
    jqm.on=JsMockito.mockFunction()
    jqm.first=JsMockito.mockFunction()
    window.mockLibrary[requestingModulePath].jqueryObjects.methodResults ?= {}

    JsMockito.when(jqm.parent)().then(()->
      ret = createMock(actual, requestingModulePath)
      window.mockLibrary[requestingModulePath].jqueryObjects.methodResults.parent = ret
      ret
    )
    JsMockito.when(jqm.children)().then(()->
      ret = createMock(actual, requestingModulePath)
      window.mockLibrary[requestingModulePath].jqueryObjects.methodResults.children = ret
      ret
    )
    JsMockito.when(jqm.first)().then(()->
      ret = createMock(actual, requestingModulePath)
      window.mockLibrary[requestingModulePath].jqueryObjects.methodResults.first = ret
      ret
    )
    JsMockito.when(jqm.attr)(JsHamcrest.Matchers.anything()).then((attrName)->
      window.mockLibrary[requestingModulePath].jqueryObjects.methodResults.attr?={}
      window.mockLibrary[requestingModulePath].jqueryObjects.methodResults.attr[attrName] = attrName+"::VALUE"
      attrName+"::VALUE"
    )

    JsMockito.when(jqm.on)(JsHamcrest.Matchers.anything(), JsHamcrest.Matchers.anything()).then(
      (eventName, cb)->
        window.mockLibrary[requestingModulePath].jqueryObjects.methodCallbacks ?= {}
        window.mockLibrary[requestingModulePath].jqueryObjects.methodCallbacks.on ?= {}
        window.mockLibrary[requestingModulePath].jqueryObjects.methodCallbacks.on[eventName]= cb
        @
    )
    jqm


  Isolate.mapAsFactory("jquery", (actual, modulePath, requestingModulePath)->
    window.mockLibrary[requestingModulePath]?= {}
    window.mockLibrary[requestingModulePath]["jqueryObjects"]={
      reset:()->
        window.mockLibrary[requestingModulePath].jqueryObjects =
          reset:window.mockLibrary[requestingModulePath].jqueryObjects.reset
          getSelectorResult:window.mockLibrary[requestingModulePath].jqueryObjects.getSelectorResult
          setSelectorResult:window.mockLibrary[requestingModulePath].jqueryObjects.setSelectorResult
        window.mockLibrary[requestingModulePath].jqueryObjects.methodResults = {}
        window.mockLibrary[requestingModulePath].jqueryObjects.methodCallbacks = {}
      getSelectorResult:(selector, context)->
        if selector is window then selector = "__WINDOW_SELECTOR_PLACEHOLDER"
        if context is window then context = "__WINDOW_CONTEXT_PLACEHOLDER"
        if (context?)
          @[selector][context]
        else
          @[selector]
      setSelectorResult:(val, selector, context)->
        if selector is window then selector = "__WINDOW_SELECTOR_PLACEHOLDER"
        if context is window then context = "__WINDOW_CONTEXT_PLACEHOLDER"
        @[selector]?={}
        if (context?)
          @[selector][context] = val
        else
          @[selector] = val
    }
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->

      mockJQuery = JsMockito.mockFunction()
      imp = (selector, context)=>

        #Without these 2 lines $(window) or $(foo, window) cause circular references when put into window.mocklibrary, which will then leak memory
        #use 'getSelectorResult passing in window where appropriate will yield the correct object
        if selector is window then selector="__WINDOW_SELECTOR_PLACEHOLDER"
        if context is window then context="__WINDOW_CONTEXT_PLACEHOLDER"

        if typeof selector is "object" and !selector.__origToString? then _.extend(selector, new UniquelyIdentifiable())
        if typeof context is "object" and !context.__origToString? then _.extend(selector, new UniquelyIdentifiable())

        mockJQueryObj =createMock(actual,requestingModulePath)
        if context?
          window.mockLibrary[requestingModulePath].jqueryObjects[selector]?=[]
          window.mockLibrary[requestingModulePath].jqueryObjects[selector][context] ?= mockJQueryObj
          window.mockLibrary[requestingModulePath].jqueryObjects[selector][context]
        else
          window.mockLibrary[requestingModulePath].jqueryObjects[selector] ?= mockJQueryObj
          window.mockLibrary[requestingModulePath].jqueryObjects[selector]

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


  Isolate.mapAsFactory("lib/turncoat/TypeRegistry", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      switch requestingModulePath
        when "lib/marshallers/JSONMarshaller"
          mockTypeRegistry =
            reverse:[]
        else
          mockTypeRegistry = actual
      mockTypeRegistry
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