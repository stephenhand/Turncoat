fakeBuiltMarshaller = {}

require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("lib/concurrency/Mutex", "lib/transports/LocalStorageTransport", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      m=
        lock:()->

      m
    )
  )
  Isolate.mapAsFactory("lib/turncoat/Factory", "lib/transports/LocalStorageTransport", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      f=
        buildStateMarshaller:()->

      f
    )
  )
)
define(["isolate!lib/transports/LocalStorageTransport"], (LocalStorageTransport)->
  MESSAGE_QUEUE = "message-queue"
  MESSAGE_ITEM = "message-item"
  CHALLENGE_RECEIVED_MESSAGE_TYPE = "challenge-received"
  mocks = window.mockLibrary["lib/transports/LocalStorageTransport"]

  suite("LocalStorageTransportTest", ()->
    data=[]
    lst= null


    mockUserQueue = null
    mockGameQueue = null
    origGet = Storage.prototype.getItem
    origSet = Storage.prototype.setItem
    origRemove = Storage.prototype.removeItem
    origClear = Storage.prototype.clear
    setup(()->
      fakeBuiltMarshaller =
        unmarshalModel:JsMockito.mockFunction()
        marshalModel:JsMockito.mockFunction()
        unmarshalState:JsMockito.mockFunction()
        marshalState:JsMockito.mockFunction()

      JsMockito.when(fakeBuiltMarshaller.marshalModel)(JsHamcrest.Matchers.anything()).then((obj)->
        JSON.stringify(obj)
      )
      JsMockito.when(fakeBuiltMarshaller.marshalState)(JsHamcrest.Matchers.anything()).then((obj)->
        JSON.stringify(obj)
      )
      JsMockito.when(fakeBuiltMarshaller.unmarshalModel)(JsHamcrest.Matchers.anything()).then((str)->
        JSON.parse(str)
      )
      JsMockito.when(fakeBuiltMarshaller.unmarshalState)(JsHamcrest.Matchers.anything()).then((str)->
        JSON.parse(str)
      )
      mockUserQueue = JSON.stringify([
        "MOCK_ID1",
        "MOCK_ID2",
        "MOCK_ID3",
        "MOCK_ID4",
        "MOCK_ID5",
        "MOCK_ID6"
      ])
      mockGameQueue = JSON.stringify([
        "MOCK_GAME_ID1",
        "MOCK_GAME_ID2",
        "MOCK_GAME_ID3",
        "MOCK_GAME_ID4",
      ])
      mockInviteReceivedMessage = JSON.stringify(
        type:CHALLENGE_RECEIVED_MESSAGE_TYPE
        payload:"MOCK_PAYLOAD"
      )
      mocks["lib/concurrency/Mutex"].lock = JsMockito.mockFunction()
      JsMockito.when(mocks["lib/concurrency/Mutex"].lock)(JsHamcrest.Matchers.func()).then((f)->
        f()
      )
      Storage.prototype.getItem=(key)->
        data[key]
      Storage.prototype.setItem=(key, val)->
        data[key]=val
      Storage.prototype.removeItem= (key)->
        delete data[key]
      Storage.prototype.clear = ()->
        data=[]
      mocks["lib/turncoat/Factory"].buildStateMarshaller = JsMockito.mockFunction()
      JsMockito.when(mocks["lib/turncoat/Factory"].buildStateMarshaller)().then(()->
        fakeBuiltMarshaller
      )
      lst = new LocalStorageTransport("MOCK_USER")
      data[MESSAGE_QUEUE+"::MOCK_USER"] = mockUserQueue
      data[MESSAGE_QUEUE+"::MOCK_USER::MOCK_GAME"] = mockGameQueue

    )
    teardown(()->
      mocks.jqueryObjects.reset()
      Storage.prototype.getItem = origGet
      Storage.prototype.setItem = origSet
      Storage.prototype.removeItem = origRemove
      Storage.prototype.clear = origClear
    )
    suite("constructor",()->
      defaultMarshaller = {}
      setup(()->
        mocks["lib/turncoat/Factory"].buildStateMarshaller = JsMockito.mockFunction()
        JsMockito.when(mocks["lib/turncoat/Factory"].buildStateMarshaller)().then(()->
          defaultMarshaller
        )
      )
      test("No marshaller supplied - builds default marshaller", ()->
        newLST = new LocalStorageTransport()
        JsMockito.verify(mocks["lib/turncoat/Factory"].buildStateMarshaller)()
        chai.assert.equal(newLST.marshaller, defaultMarshaller)
      )
      test("Marshaller supplied - uses provided marshaller", ()->
        marshaller = {}
        newLST = new LocalStorageTransport("","",marshaller)
        JsMockito.verify(mocks["lib/turncoat/Factory"].buildStateMarshaller, JsMockito.Verifiers.never())()
        chai.assert.equal(newLST.marshaller, marshaller)
      )
    )
    suite("startListening", ()->
      setup(()->

        lst.trigger = JsMockito.mockFunction()
        calls = 0
        JsMockito.when(lst.trigger)(JsHamcrest.Matchers.anything(),JsHamcrest.Matchers.anything()).then(()->
          calls++
        )
      )
      test("Binds To LocalStorageChanged Event", ()->
        lst.startListening()
        JsMockito.verify(mocks.jqueryObjects.getSelectorResult(window).on)("storage", JsHamcrest.Matchers.func())
      )
      test("Multiple calls - only binds to LocalStorageChanged Event once", ()->
        lst.startListening()
        lst.startListening()
        lst.startListening()
        lst.startListening()
        JsMockito.verify(mocks.jqueryObjects.getSelectorResult(window).on)("storage", JsHamcrest.Matchers.func())
      )
      suite("LocalStorageChanged event handler", ()->
        suite("Matches transport's user queue name", ()->
          setup(()->
            data[MESSAGE_ITEM+"::MOCK_ID1"]=JSON.stringify(
              type:CHALLENGE_RECEIVED_MESSAGE_TYPE
              payload:
                propA:"SOMETHING"
            )
          )
          test("Enters mutex, shifts item and saves it back", ()->
            lst.startListening()
            JsMockito.verify(mocks.jqueryObjects.getSelectorResult(window).on)(
              "storage",
              new JsHamcrest.SimpleMatcher(
                matches:(f)->
                  f(
                    originalEvent:
                      key: MESSAGE_QUEUE+"::MOCK_USER"
                  )
                  try
                    JsMockito.verify(mocks["lib/concurrency/Mutex"].lock)(
                      JsHamcrest.Matchers.allOf(
                        JsHamcrest.Matchers.hasMember("criticalSection",
                          new JsHamcrest.SimpleMatcher(
                            matches:(mf)->
                              try
                                chai.assert.equal(mockUserQueue, data[MESSAGE_QUEUE+"::MOCK_USER"])
                                mf()
                                chai.assert.equal(JSON.stringify([
                                  "MOCK_ID2",
                                  "MOCK_ID3",
                                  "MOCK_ID4",
                                  "MOCK_ID5",
                                  "MOCK_ID6"
                                ]), data[MESSAGE_QUEUE+"::MOCK_USER"])
                                true
                              catch e
                                false

                          )
                        ),
                        JsHamcrest.Matchers.hasMember("success", JsHamcrest.Matchers.func())
                      )
                    )
                    true
                  catch e
                    false
              )
            )
          )
          test("Uses marshaller marshalState / unmarshalState", ()->
            lst.startListening()
            JsMockito.verify(mocks.jqueryObjects.getSelectorResult(window).on)(
              "storage",
              new JsHamcrest.SimpleMatcher(
                matches:(f)->
                  f(
                    originalEvent:
                      key: MESSAGE_QUEUE+"::MOCK_USER"
                  )
                  try
                    JsMockito.verify(mocks["lib/concurrency/Mutex"].lock)(
                      JsHamcrest.Matchers.hasMember("criticalSection",
                        new JsHamcrest.SimpleMatcher(
                          matches:(mf)->
                            try
                              orig = data[MESSAGE_QUEUE+"::MOCK_USER"]
                              mf()
                              JsMockito.verify(fakeBuiltMarshaller.unmarshalState)(orig)
                              JsMockito.verify(fakeBuiltMarshaller.marshalState)(JsHamcrest.Matchers.equivalentArray([
                                "MOCK_ID2",
                                "MOCK_ID3",
                                "MOCK_ID4",
                                "MOCK_ID5",
                                "MOCK_ID6"
                              ]))
                              true
                            catch e
                              false

                        )
                      )
                    )
                    true
                  catch e
                    false
              )
            )
          )
          test("Uses marshaller unmarshalModel on located item", ()->
            lst.startListening()
            JsMockito.verify(mocks.jqueryObjects.getSelectorResult(window).on)(
              "storage",
              new JsHamcrest.SimpleMatcher(
                matches:(f)->
                  f(
                    originalEvent:
                      key: MESSAGE_QUEUE+"::MOCK_USER"
                  )
                  try
                    JsMockito.verify(mocks["lib/concurrency/Mutex"].lock)(
                      new JsHamcrest.SimpleMatcher(
                        matches:(o)->
                          try
                            o.criticalSection()
                            o.success()
                            JsMockito.verify(fakeBuiltMarshaller.unmarshalModel)(data[MESSAGE_ITEM+"::MOCK_ID1"])
                            true
                          catch e
                            false
                      )
                    )
                    true
                  catch e
                    false
              )
            )
          )
          test("Envelope has payload and 'Challenge Received' type - triggers 'Challenge Recieved' event from transport with payload", ()->

            lst.startListening()
            JsMockito.verify(mocks.jqueryObjects.getSelectorResult(window).on)(
              "storage",
              new JsHamcrest.SimpleMatcher(
                matches:(f)->
                  f(
                    originalEvent:
                      key: MESSAGE_QUEUE+"::MOCK_USER"
                  )
                  try
                    JsMockito.verify(mocks["lib/concurrency/Mutex"].lock)(
                      new JsHamcrest.SimpleMatcher(
                        matches:(o)->
                          try
                            o.criticalSection()
                            o.success()
                            JsMockito.verify(lst.trigger)("challengeReceived",JsHamcrest.Matchers.hasMember("propA", "SOMETHING"))
                            true
                          catch e
                            false
                      )
                    )
                    true
                  catch e
                    false
              )
            )
          )
        )
      )
    )
    suite("stopListening", ()->
      test("Unbinds To LocalStorageChanged Event", ()->
        lst.startListening()
        lst.stopListening()
        JsMockito.verify(mocks.jqueryObjects.getSelectorResult(window).off)("storage", mocks.jqueryObjects.methodCallbacks.on["storage"])
      )
      test("Multiple calls - only unbinds from LocalStorageChanged Event once", ()->
        lst.startListening()
        lst.stopListening()
        lst.stopListening()
        lst.stopListening()
        JsMockito.verify(mocks.jqueryObjects.getSelectorResult(window).off)("storage", mocks.jqueryObjects.methodCallbacks.on["storage"])
      )
      test("Calls without prior start listening - does nothing", ()->
        mocks.jqueryObjects.getSelectorResult(window).off = JsMockito.mockFunction()
        lst.stopListening()
        JsMockito.verify(mocks.jqueryObjects.getSelectorResult(window).off, JsMockito.Verifiers.never())("storage", JsHamcrest.Matchers.func())
      )
      test("Multiple start and stoplistening calls -LocalStorageChanged Event only binds and unbinds when listening state toggles", ()->
        lst.startListening()
        JsMockito.verify(mocks.jqueryObjects.getSelectorResult(window).on)("storage", JsHamcrest.Matchers.func())
        lst.stopListening()
        JsMockito.verify(mocks.jqueryObjects.getSelectorResult(window).off)("storage", mocks.jqueryObjects.methodCallbacks.on["storage"])
        lst.stopListening()
        lst.startListening()
        JsMockito.verify(mocks.jqueryObjects.getSelectorResult(window).on)("storage", JsHamcrest.Matchers.func())
        lst.startListening()
        lst.startListening()
        lst.stopListening()
        JsMockito.verify(mocks.jqueryObjects.getSelectorResult(window).off)("storage", mocks.jqueryObjects.methodCallbacks.on["storage"])
        lst.startListening()
        JsMockito.verify(mocks.jqueryObjects.getSelectorResult(window).on)("storage", JsHamcrest.Matchers.func())
        lst.stopListening()
        JsMockito.verify(mocks.jqueryObjects.getSelectorResult(window).off)("storage", mocks.jqueryObjects.methodCallbacks.on["storage"])
        lst.stopListening()
      )
    )
  )


)

