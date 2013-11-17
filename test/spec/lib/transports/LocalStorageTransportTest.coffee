fakeBuiltMarshaller = {}
dispatcher = null

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
        registerTransport:JsMockito.mockFunction()

      f
    )
  )
  Isolate.mapAsFactory("backbone", "lib/transports/LocalStorageTransport", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      Events:
        on:()->
          dispatcher = @
        off:()->
      Model:actual.Model
    )
  )
  Isolate.mapAsFactory("uuid", "lib/transports/LocalStorageTransport", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      ()->
        "MOCK_GENERATED_ID"
    )
  )
)
define(["isolate!lib/transports/LocalStorageTransport", "backbone"], (LocalStorageTransport, Backbone)->
  MESSAGE_QUEUE = "message-queue"
  MESSAGE_ITEM = "message-item"
  CHALLENGE_ISSUED_MESSAGE_TYPE = "challenge-issued"
  mocks = window.mockLibrary["lib/transports/LocalStorageTransport"]

  suite("LocalStorageTransportTest", ()->
    data=[]
    lst= null

    mockUserSingleItemQueue = null
    mockUserQueue = null
    mockGameQueue = null
    origGet = Storage.prototype.getItem
    origSet = Storage.prototype.setItem
    origRemove = Storage.prototype.removeItem
    origClear = Storage.prototype.clear
    setupMarshaller = ()->
      fakeBuiltMarshaller.unmarshalModel=JsMockito.mockFunction()
      fakeBuiltMarshaller.marshalModel=JsMockito.mockFunction()
      fakeBuiltMarshaller.unmarshalState=JsMockito.mockFunction()
      fakeBuiltMarshaller.marshalState=JsMockito.mockFunction()
      JsMockito.when(fakeBuiltMarshaller.marshalModel)(JsHamcrest.Matchers.anything()).then((obj)->
        JSON.stringify(obj)
      )
      JsMockito.when(fakeBuiltMarshaller.marshalState)(JsHamcrest.Matchers.anything()).then((obj)->
        JSON.stringify(obj)
      )
      JsMockito.when(fakeBuiltMarshaller.unmarshalModel)(JsHamcrest.Matchers.anything()).then((str)->
        new Backbone.Collection(JSON.parse(str))
      )
      JsMockito.when(fakeBuiltMarshaller.unmarshalState)(JsHamcrest.Matchers.anything()).then((str)->
        new Backbone.Model(JSON.parse(str))
      )
    setup(()->
      fakeBuiltMarshaller = {}
      setupMarshaller()

      mockUserSingleItemQueue = JSON.stringify([
        id:"MOCK_ID1"
      ])
      mockUserQueue = JSON.stringify([
        id:"MOCK_ID1"
      ,
        id:"MOCK_ID2"
      ,
        id:"MOCK_ID3"
      ])
      mockGameQueue = JSON.stringify([
        id:"MOCK_GAME_ID1"
      ])
      mockInviteReceivedMessage = JSON.stringify(
        type:CHALLENGE_ISSUED_MESSAGE_TYPE
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
      lst = new LocalStorageTransport(userId:"MOCK_USER")
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
      test("Sets userId to userId of supplied options", ()->
        newLST = new LocalStorageTransport(userId:"TEST_USER_ID")
        chai.assert.equal(newLST.userId, "TEST_USER_ID")
      )
      test("Sets gameId to gameId of supplied options", ()->
        newLST = new LocalStorageTransport(gameId:"TEST_GAME_ID")
        chai.assert.equal(newLST.gameId, "TEST_GAME_ID")
      )
      test("No marshaller supplied - builds default marshaller", ()->
        newLST = new LocalStorageTransport()
        JsMockito.verify(mocks["lib/turncoat/Factory"].buildStateMarshaller)()
        chai.assert.equal(newLST.marshaller, defaultMarshaller)
      )
      test("Marshaller supplied - uses provided marshaller", ()->
        marshaller = {}
        newLST = new LocalStorageTransport(marshaller:marshaller)
        JsMockito.verify(mocks["lib/turncoat/Factory"].buildStateMarshaller, JsMockito.Verifiers.never())()
        chai.assert.equal(newLST.marshaller, marshaller)
      )
    )
    suite("startListening", ()->
      setup(()->
        #set dispatcher
        new LocalStorageTransport().startListening()
        dispatcher.on = JsMockito.mockFunction()
        data[MESSAGE_QUEUE+"::MOCK_USER"] = mockUserSingleItemQueue
        lst.trigger = JsMockito.mockFunction()

      )
      test("Empty starting queue - does nothing except load & save empty queue.", ()->

        mocks["lib/concurrency/Mutex"].lock = JsMockito.mockFunction()
        data[MESSAGE_QUEUE+"::MOCK_USER"] = JSON.stringify([])
        lst.startListening()
        setupMarshaller()
        JsMockito.verify(mocks["lib/concurrency/Mutex"].lock)(
          new JsHamcrest.SimpleMatcher(
            describeTo:(d)->d.append("mutext options")
            matches:(o)->
              try
                o.criticalSection()
                JsMockito.verify(fakeBuiltMarshaller.unmarshalModel)(JSON.stringify([]))
                JsMockito.verify(fakeBuiltMarshaller.marshalModel)(JsHamcrest.Matchers.hasMember("models",JsHamcrest.Matchers.equivalentArray([])))
                o.success()
                JsMockito.verify(fakeBuiltMarshaller.unmarshalState, JsMockito.Verifiers.never())(JsHamcrest.Matchers.anything())
                true
              catch e
                false

          )
        )
      )
      suite("Multiple items in queue", ()->
        setup(()->
          data[MESSAGE_QUEUE+"::MOCK_USER"] = mockUserQueue
          data[MESSAGE_ITEM+"::MOCK_ID1"]=JSON.stringify(
            type:CHALLENGE_ISSUED_MESSAGE_TYPE
            payload:
              propA:"SOMETHING"
          )
          data[MESSAGE_ITEM+"::MOCK_ID2"]=JSON.stringify(
            type:CHALLENGE_ISSUED_MESSAGE_TYPE
            payload:
              propA:"SOMETHING1"
          )
          data[MESSAGE_ITEM+"::MOCK_ID3"]=JSON.stringify(
            type:CHALLENGE_ISSUED_MESSAGE_TYPE
            payload:
              propA:"SOMETHING2"
          )
          mocks["lib/concurrency/Mutex"].lock = JsMockito.mockFunction()
          JsMockito.when(mocks["lib/concurrency/Mutex"].lock)(JsHamcrest.Matchers.anything()).then((o)->
            try
              o.criticalSection()
            catch e
              o.error(e)
            o.success()
          )
        )
        test("Dequeue sequence for each message", ()->
          items = [data[MESSAGE_ITEM+"::MOCK_ID1"],data[MESSAGE_ITEM+"::MOCK_ID2"],data[MESSAGE_ITEM+"::MOCK_ID3"]]
          lst.startListening()
          JsMockito.verify(mocks["lib/concurrency/Mutex"].lock, JsMockito.Verifiers.times(3))(JsHamcrest.Matchers.anything())

          JsMockito.verify(fakeBuiltMarshaller.unmarshalModel)(JSON.stringify([
            id:"MOCK_ID1"
          ,
            id:"MOCK_ID2"
          ,
            id:"MOCK_ID3"
          ]))
          JsMockito.verify(fakeBuiltMarshaller.marshalModel)(JsHamcrest.Matchers.hasMember("models",
            JsHamcrest.Matchers.allOf(
              JsHamcrest.Matchers.hasItems(
                JsHamcrest.Matchers.hasMember("id","MOCK_ID2")
              ,
                JsHamcrest.Matchers.hasMember("id","MOCK_ID3")
              )
            ,
              JsHamcrest.Matchers.hasSize(2)
            )
          ))
          JsMockito.verify(fakeBuiltMarshaller.unmarshalState)(items[0])
          JsMockito.verify(fakeBuiltMarshaller.unmarshalModel)(JSON.stringify([
            id:"MOCK_ID2"
          ,
            id:"MOCK_ID3"
          ]))
          JsMockito.verify(fakeBuiltMarshaller.marshalModel)(
            JsHamcrest.Matchers.hasMember("models",
              JsHamcrest.Matchers.allOf(
                JsHamcrest.Matchers.hasItems(
                  JsHamcrest.Matchers.hasMember("id","MOCK_ID3")
                )
              ,
                JsHamcrest.Matchers.hasSize(1)
              )
            )
          )
          JsMockito.verify(fakeBuiltMarshaller.unmarshalState)(items[1])
          JsMockito.verify(fakeBuiltMarshaller.unmarshalModel)(JSON.stringify([
            id:"MOCK_ID3"
          ]))
          JsMockito.verify(fakeBuiltMarshaller.marshalModel)(
            JsHamcrest.Matchers.hasMember("models",
              JsHamcrest.Matchers.empty()
            )
          )
          JsMockito.verify(fakeBuiltMarshaller.unmarshalState)(items[2])

        )
      )
      test("Binds to dispatcher queueModified event", ()->
        lst.startListening()
        JsMockito.verify(dispatcher.on)("queueModified", JsHamcrest.Matchers.func())
      )
      test("Binds To LocalStorageChanged Event", ()->
        lst.startListening()
        JsMockito.verify(mocks.jqueryObjects.getSelectorResult(window).on)("storage", JsHamcrest.Matchers.func())
      )
      test("Multiple calls - only binds to dispatcher queueModified event once", ()->
        lst.startListening()
        lst.startListening()
        lst.startListening()
        lst.startListening()
        JsMockito.verify(dispatcher.on)("queueModified", JsHamcrest.Matchers.func())
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
      suite("Storage event handler", ()->
        setup(()->
          data[MESSAGE_QUEUE+"::A_USER_ID"]=mockUserSingleItemQueue
          data[MESSAGE_QUEUE+"::A_USER_ID::A_GAME_ID"]=mockGameQueue
          data[MESSAGE_ITEM+"::MOCK_ID1"]=JSON.stringify(
            type:CHALLENGE_ISSUED_MESSAGE_TYPE
            payload:
              propA:"SOMETHING"
          )
          data[MESSAGE_ITEM+"::MOCK_GAME_ID1"]=JSON.stringify(
            type:CHALLENGE_ISSUED_MESSAGE_TYPE
            payload:
              propA:"SOMETHING"
          )
        )
        test("Matches queue identifier prefix - enters same mutex as dispatcher using userId from queue name", ()->
          lst = new LocalStorageTransport(userId:"A_USER_ID")
          lst.startListening()
          JsMockito.verify(mocks.jqueryObjects.getSelectorResult(window).on)(
            "storage",
            new JsHamcrest.SimpleMatcher(
              matches:(f)->
                f(
                  originalEvent:
                    key: MESSAGE_QUEUE+"::A_USER_ID"
                )
                try
                  JsMockito.verify(mocks["lib/concurrency/Mutex"].lock)(
                    new JsHamcrest.SimpleMatcher(
                      describeTo:(d)->
                        d.append("valid criticalSection.")
                      matches:(o)->
                        try

                          chai.assert.equal(mockUserSingleItemQueue, data[MESSAGE_QUEUE+"::A_USER_ID"])
                          o.criticalSection()
                          chai.assert.equal(JSON.stringify([]), data[MESSAGE_QUEUE+"::A_USER_ID"])
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
        test("Matches queue identifier prefix with game - enters same mutex as dispatcher using gameId and userId from queue name", ()->
          lst = new LocalStorageTransport(
            userId:"A_USER_ID"
            gameId:"A_GAME_ID"
          )
          lst.startListening()
          JsMockito.verify(mocks.jqueryObjects.getSelectorResult(window).on)(
            "storage",
            new JsHamcrest.SimpleMatcher(
              matches:(f)->
                f(
                  originalEvent:
                    key: MESSAGE_QUEUE+"::A_USER_ID::A_GAME_ID"
                )
                try
                  JsMockito.verify(mocks["lib/concurrency/Mutex"].lock)(
                    new JsHamcrest.SimpleMatcher(
                      describeTo:(d)->
                        d.append("valid criticalSection.")
                      matches:(o)->
                        try
                          chai.assert.equal(mockGameQueue, data[MESSAGE_QUEUE+"::A_USER_ID::A_GAME_ID"])
                          o.criticalSection()
                          chai.assert.equal(JSON.stringify([]), data[MESSAGE_QUEUE+"::A_USER_ID::A_GAME_ID"])
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
        test("Not queue identifier prefix - does nothing", ()->
          dispatcherHandler = JsMockito.mockFunction()
          JsMockito.when(dispatcher.on)("queueModified", JsHamcrest.Matchers.func()).then(dispatcherHandler)
          lst.startListening()
          mocks["lib/concurrency/Mutex"].lock = JsMockito.mockFunction()
          JsMockito.verify(mocks.jqueryObjects.getSelectorResult(window).on)(
            "storage",
            new JsHamcrest.SimpleMatcher(
              matches:(f)->
                f(
                  originalEvent:
                    key:"NOT_A_MESSAGE_QUEUE::A_USER_ID::A_GAME_ID"
                )
                try

                  JsMockito.verify(mocks["lib/concurrency/Mutex"].lock, JsMockito.Verifiers.never())(JsHamcrest.Matchers.anything())
                  true
                catch e
                  false
            )
          )
        )
      )
      suite("dispatcher queueModified event handler", ()->
        setup(()->
          lst.startListening()
          setupMarshaller()
          data[MESSAGE_QUEUE+"::MOCK_USER"] = mockUserSingleItemQueue
          lst.trigger = JsMockito.mockFunction()
          mocks["lib/concurrency/Mutex"].lock = JsMockito.mockFunction()
          JsMockito.when(mocks["lib/concurrency/Mutex"].lock)(JsHamcrest.Matchers.func()).then((f)->
            f()
          )
        )
        suite("Matches transport's user queue name", ()->
          setup(()->
            data[MESSAGE_ITEM+"::MOCK_ID1"]=JSON.stringify(
              type:CHALLENGE_ISSUED_MESSAGE_TYPE
              payload:
                propA:"SOMETHING"
            )
          )
          test("Enters mutex, shifts item and saves it back", ()->
            JsMockito.verify(dispatcher.on)(
              "queueModified",
              new JsHamcrest.SimpleMatcher(
                describeTo:(d)->
                  d.append("valid queueModified handler.")
                matches:(f)->
                  f(
                    userId:"MOCK_USER"
                  )
                  try
                    JsMockito.verify(mocks["lib/concurrency/Mutex"].lock)(
                      JsHamcrest.Matchers.allOf(
                        JsHamcrest.Matchers.hasMember("criticalSection",
                          new JsHamcrest.SimpleMatcher(
                            describeTo:(d)->
                              d.append("valid criticalSection.")
                            matches:(mf)->
                              try
                                chai.assert.equal(mockUserSingleItemQueue, data[MESSAGE_QUEUE+"::MOCK_USER"])
                                mf()
                                chai.assert.equal(JSON.stringify([]), data[MESSAGE_QUEUE+"::MOCK_USER"])
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
            JsMockito.verify(dispatcher.on)(
              "queueModified",
              new JsHamcrest.SimpleMatcher(
                describeTo:(d)->
                  d.append("valid queueModified handler.")
                matches:(f)->
                  f(
                    userId:"MOCK_USER"
                  )
                  try
                    JsMockito.verify(mocks["lib/concurrency/Mutex"].lock)(
                      JsHamcrest.Matchers.hasMember("criticalSection",
                        new JsHamcrest.SimpleMatcher(
                          matches:(mf)->
                            try
                              orig = data[MESSAGE_QUEUE+"::MOCK_USER"]
                              mf()
                              JsMockito.verify(fakeBuiltMarshaller.unmarshalModel)(orig)
                              JsMockito.verify(fakeBuiltMarshaller.marshalModel)(
                                JsHamcrest.Matchers.hasMember("models",JsHamcrest.Matchers.equivalentArray([]))
                              )
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
          test("Absent queue - does nothing.", ()->
            delete data[MESSAGE_QUEUE+"::MOCK_USER"]
            JsMockito.verify(dispatcher.on)(
              "queueModified",
              new JsHamcrest.SimpleMatcher(
                describeTo:(d)->
                  d.append("valid queueModified handler.")
                matches:(f)->
                  f(
                    userId:"MOCK_USER"
                  )
                  try
                    JsMockito.verify(mocks["lib/concurrency/Mutex"].lock)(
                      new JsHamcrest.SimpleMatcher(
                        matches:(o)->
                          try
                            o.criticalSection()
                            JsMockito.verify(fakeBuiltMarshaller.unmarshalModel, JsMockito.Verifiers.never())(JsHamcrest.Matchers.anything())
                            JsMockito.verify(fakeBuiltMarshaller.marshalModel, JsMockito.Verifiers.never())(JsHamcrest.Matchers.anything())
                            o.success()
                            JsMockito.verify(fakeBuiltMarshaller.unmarshalState, JsMockito.Verifiers.never())(JsHamcrest.Matchers.anything())
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
          test("Empty queue - does nothing except load & save empty queue.", ()->
            data[MESSAGE_QUEUE+"::MOCK_USER"] = JSON.stringify([])
            JsMockito.verify(dispatcher.on)(
              "queueModified",
              new JsHamcrest.SimpleMatcher(
                describeTo:(d)->
                  d.append("valid queueModified handler.")
                matches:(f)->
                  f(
                    userId:"MOCK_USER"
                  )
                  try
                    JsMockito.verify(mocks["lib/concurrency/Mutex"].lock)(
                      new JsHamcrest.SimpleMatcher(
                        matches:(o)->
                          try
                            o.criticalSection()
                            JsMockito.verify(fakeBuiltMarshaller.unmarshalModel)(JSON.stringify([]))
                            JsMockito.verify(fakeBuiltMarshaller.marshalModel)(JsHamcrest.Matchers.hasMember("models",
                              JsHamcrest.Matchers.equivalentArray([]))
                            )
                            o.success()
                            JsMockito.verify(fakeBuiltMarshaller.unmarshalState, JsMockito.Verifiers.never())(JsHamcrest.Matchers.anything())
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
          test("Message item identified in queue not found in storage - critical section throws", ()->
            delete data[MESSAGE_ITEM+"::MOCK_ID1"]
            JsMockito.verify(dispatcher.on)(
              "queueModified",
              new JsHamcrest.SimpleMatcher(
                describeTo:(d)->
                  d.append("valid queueModified handler.")
                matches:(f)->
                  f(
                    userId:"MOCK_USER"
                  )
                  try
                    JsMockito.verify(mocks["lib/concurrency/Mutex"].lock)(
                      new JsHamcrest.SimpleMatcher(
                        matches:(o)->
                          try
                            o.criticalSection()
                            false
                          catch e
                            true
                      )
                    )
                    true
                  catch e
                    false
              )
            )
          )
          test("Uses marshaller unmarshalState on located item", ()->
            JsMockito.verify(dispatcher.on)(
              "queueModified",
              new JsHamcrest.SimpleMatcher(
                describeTo:(d)->
                  d.append("valid queueModified handler.")
                matches:(f)->
                  f(
                    userId:"MOCK_USER"
                  )
                  try
                    JsMockito.verify(mocks["lib/concurrency/Mutex"].lock)(
                      new JsHamcrest.SimpleMatcher(
                        matches:(o)->
                          try
                            payloadData = data[MESSAGE_ITEM+"::MOCK_ID1"]
                            o.criticalSection()
                            o.success()
                            JsMockito.verify(fakeBuiltMarshaller.unmarshalState)(payloadData)
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

            JsMockito.verify(dispatcher.on)(
              "queueModified",
              new JsHamcrest.SimpleMatcher(
                describeTo:(d)->
                  d.append("valid queueModified handler.")
                matches:(f)->
                  f(
                    userId:"MOCK_USER"
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
          test("Deletes stored payload.", ()->
            JsMockito.verify(dispatcher.on)(
              "queueModified",
              new JsHamcrest.SimpleMatcher(
                describeTo:(d)->
                  d.append("valid queueModified handler.")
                matches:(f)->
                  f(
                    userId:"MOCK_USER"
                  )
                  try
                    JsMockito.verify(mocks["lib/concurrency/Mutex"].lock)(
                      new JsHamcrest.SimpleMatcher(
                        matches:(o)->
                          try
                            o.criticalSection()
                            o.success()
                            chai.assert.isUndefined(data[MESSAGE_ITEM+"::MOCK_ID1"])
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

          suite("Multiple items in queue", ()->
            setup(()->
              data[MESSAGE_QUEUE+"::MOCK_USER"] = mockUserQueue
              data[MESSAGE_ITEM+"::MOCK_ID2"]=JSON.stringify(
                type:CHALLENGE_ISSUED_MESSAGE_TYPE
                payload:
                  propA:"SOMETHING1"
              )
              data[MESSAGE_ITEM+"::MOCK_ID3"]=JSON.stringify(
                type:CHALLENGE_ISSUED_MESSAGE_TYPE
                payload:
                  propA:"SOMETHING2"
              )
              JsMockito.when(mocks["lib/concurrency/Mutex"].lock)(JsHamcrest.Matchers.anything()).then((o)->
                try
                  o.criticalSection()
                catch e
                  o.error(e)
                o.success()
              )
            )
            test("Continues dequeue sequence for each message", ()->
              JsMockito.verify(dispatcher.on)(
                "queueModified",
                new JsHamcrest.SimpleMatcher(
                  describeTo:(d)->
                    d.append("valid queueModified handler.")
                  matches:(f)->
                    items = [data[MESSAGE_ITEM+"::MOCK_ID1"],data[MESSAGE_ITEM+"::MOCK_ID2"],data[MESSAGE_ITEM+"::MOCK_ID3"]]
                    f(
                      userId:"MOCK_USER"
                    )
                    try
                      JsMockito.verify(mocks["lib/concurrency/Mutex"].lock, JsMockito.Verifiers.times(3))(JsHamcrest.Matchers.anything())

                      JsMockito.verify(fakeBuiltMarshaller.unmarshalModel)(JSON.stringify([
                        id:"MOCK_ID1"
                      ,
                        id:"MOCK_ID2"
                      ,
                        id:"MOCK_ID3"
                      ]))
                      JsMockito.verify(fakeBuiltMarshaller.marshalModel)(JsHamcrest.Matchers.hasMember("models",
                        JsHamcrest.Matchers.allOf(
                          JsHamcrest.Matchers.hasItems(
                            JsHamcrest.Matchers.hasMember("id","MOCK_ID2")
                          ,
                            JsHamcrest.Matchers.hasMember("id","MOCK_ID3")
                          )
                        ,
                          JsHamcrest.Matchers.hasSize(2)
                        ))
                      )
                      JsMockito.verify(fakeBuiltMarshaller.unmarshalState)(items[0])
                      JsMockito.verify(fakeBuiltMarshaller.unmarshalModel)(JSON.stringify([
                        id:"MOCK_ID2"
                      ,
                        id:"MOCK_ID3"
                      ]))
                      JsMockito.verify(fakeBuiltMarshaller.marshalModel)(JsHamcrest.Matchers.hasMember("models",
                        JsHamcrest.Matchers.allOf(
                          JsHamcrest.Matchers.hasItem(
                            JsHamcrest.Matchers.hasMember("id","MOCK_ID3")
                          )
                        ,
                          JsHamcrest.Matchers.hasSize(1)
                        )
                      ))
                      JsMockito.verify(fakeBuiltMarshaller.unmarshalState)(items[1])
                      JsMockito.verify(fakeBuiltMarshaller.unmarshalModel)(JSON.stringify([
                        id:"MOCK_ID3"
                      ]))
                      JsMockito.verify(fakeBuiltMarshaller.marshalModel)(JsHamcrest.Matchers.empty())
                      JsMockito.verify(fakeBuiltMarshaller.unmarshalState)(items[2])
                      true
                    catch e
                      false
                )
              )
            )
            test("Continues dequeue sequence if missing message is hit", ()->
              delete data[MESSAGE_ITEM+"::MOCK_ID2"]
              JsMockito.verify(dispatcher.on)(
                "queueModified",
                new JsHamcrest.SimpleMatcher(
                  describeTo:(d)->
                    d.append("valid queueModified handler.")
                  matches:(f)->
                    items = [data[MESSAGE_ITEM+"::MOCK_ID1"],data[MESSAGE_ITEM+"::MOCK_ID2"],data[MESSAGE_ITEM+"::MOCK_ID3"]]
                    f(
                      userId:"MOCK_USER"
                    )
                    try
                      JsMockito.verify(mocks["lib/concurrency/Mutex"].lock, JsMockito.Verifiers.times(3))(JsHamcrest.Matchers.anything())

                      JsMockito.verify(fakeBuiltMarshaller.unmarshalModel)(JSON.stringify([
                        id:"MOCK_ID1"
                      ,
                        id:"MOCK_ID2"
                      ,
                        id:"MOCK_ID3"
                      ]))
                      JsMockito.verify(fakeBuiltMarshaller.marshalModel)(JsHamcrest.Matchers.hasMember("models",
                        JsHamcrest.Matchers.allOf(
                          JsHamcrest.Matchers.hasItems(
                            JsHamcrest.Matchers.hasMember("id","MOCK_ID2")
                          ,
                            JsHamcrest.Matchers.hasMember("id","MOCK_ID3")
                          )
                        ,
                          JsHamcrest.Matchers.hasSize(2)
                        ))
                      )
                      JsMockito.verify(fakeBuiltMarshaller.unmarshalState)(items[0])
                      JsMockito.verify(fakeBuiltMarshaller.unmarshalModel)(JSON.stringify([
                        id:"MOCK_ID2"
                      ,
                        id:"MOCK_ID3"
                      ]))
                      JsMockito.verify(fakeBuiltMarshaller.marshalModel)(JsHamcrest.Matchers.hasMember("models",
                        JsHamcrest.Matchers.allOf(
                          JsHamcrest.Matchers.hasItem(
                            JsHamcrest.Matchers.hasMember("id","MOCK_ID3")
                          )
                        ,
                          JsHamcrest.Matchers.hasSize(1)
                        )
                      ))
                      JsMockito.verify(fakeBuiltMarshaller.unmarshalState, JsMockito.Verifiers.never())(items[1])
                      JsMockito.verify(fakeBuiltMarshaller.unmarshalModel)(JSON.stringify([
                        id:"MOCK_ID3"
                      ]))
                      JsMockito.verify(fakeBuiltMarshaller.marshalModel)(JsHamcrest.Matchers.hasMember("models",
                        JsHamcrest.Matchers.empty()
                      ))
                      JsMockito.verify(fakeBuiltMarshaller.unmarshalState)(items[2])
                      true
                    catch e
                      false
                )
              )
            )
          )
        )
      )
    )
    suite("stopListening", ()->
      dispatcherHandler = null
      setup(()->
        #set dispatcher
        new LocalStorageTransport().startListening()
        dispatcher.on = JsMockito.mockFunction()
        dispatcher.off = JsMockito.mockFunction()
        JsMockito.when(dispatcher.on)(JsHamcrest.Matchers.anything(),JsHamcrest.Matchers.anything()).then((n, h)->dispatcherHandler=h)
      )
      test("Unbinds dispatcher event", ()->
        lst.startListening()
        lst.stopListening()
        JsMockito.verify(dispatcher.off)("queueModified", dispatcherHandler)
      )
      test("Multiple calls - only unbinds from LocalStorageChanged Event once", ()->
        lst.startListening()
        lst.stopListening()
        lst.stopListening()
        lst.stopListening()
        JsMockito.verify(dispatcher.off)("queueModified", dispatcherHandler)
      )
      test("Calls without prior start listening - does nothing", ()->
        lst.stopListening()
        JsMockito.verify(dispatcher.off, JsMockito.Verifiers.never())("queueModified", JsHamcrest.Matchers.func())
      )
      test("Multiple start and stoplistening calls -LocalStorageChanged Event only binds and unbinds when listening state toggles", ()->
        lst.startListening()
        JsMockito.verify(dispatcher.on)("queueModified", dispatcherHandler)
        lst.stopListening()
        JsMockito.verify(dispatcher.off)("queueModified", dispatcherHandler)
        lst.stopListening()
        lst.startListening()
        JsMockito.verify(dispatcher.on)("queueModified", dispatcherHandler)
        lst.startListening()
        lst.startListening()
        lst.stopListening()
        JsMockito.verify(dispatcher.off)("queueModified", dispatcherHandler)
        lst.startListening()
        JsMockito.verify(dispatcher.on)("queueModified", dispatcherHandler)
        lst.stopListening()
        JsMockito.verify(dispatcher.off)("queueModified", dispatcherHandler)
        lst.stopListening()
      )
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
    suite("sendChallenge", ()->
      test("No existing target user queue - creates queue in mutex",()->
        delete data[MESSAGE_QUEUE+"::MOCK_USER"]
        lst.sendChallenge("MOCK_USER", {})
        JsMockito.verify(mocks["lib/concurrency/Mutex"].lock)(
          new JsHamcrest.SimpleMatcher(
            matches:(o)->
              o.criticalSection()
              JSON.parse(data[MESSAGE_QUEUE+"::MOCK_USER"]).length is 1
          )

        )
      )
      test("Existing target user queue empty - creates first queue item in mutex", ()->
        data[MESSAGE_QUEUE+"::MOCK_USER"] = JSON.stringify([])
        lst.sendChallenge("MOCK_USER", {})
        JsMockito.verify(mocks["lib/concurrency/Mutex"].lock)(
          new JsHamcrest.SimpleMatcher(
            matches:(o)->
              o.criticalSection()
              JSON.parse(data[MESSAGE_QUEUE+"::MOCK_USER"]).length is 1
          )

        )
      )
      suite("Multiple items already in queue", ()->
        setup(()->
          data[MESSAGE_QUEUE+"::MOCK_USER"] = JSON.stringify([
            id:"MESSAGE1"
          ,
            id:"MESSAGE2"
          ,
            id:"MESSAGE3"
          ,
            id:"MESSAGE4"
          ])
        )
        test("Adds new item to the end of the queue in mutex", ()->
          existing = JSON.parse(data[MESSAGE_QUEUE+"::MOCK_USER"]).length
          lst.sendChallenge("MOCK_USER",
            propA:"SOMETHING"
          )
          JsMockito.verify(mocks["lib/concurrency/Mutex"].lock)(
            new JsHamcrest.SimpleMatcher(
              matches:(o)->
                o.criticalSection()
                JSON.parse(data[MESSAGE_QUEUE+"::MOCK_USER"]).length is existing+1
            )
          )
        )
        test("Generates ID and saves data so local storage location based on it before entering critical section", ()->
          lst.sendChallenge("MOCK_USER",
            propA:"SOMETHING"
          )
          chai.assert.isDefined(data[MESSAGE_ITEM+"::MOCK_GENERATED_ID"])
        )
        test("Queued ID matches id of saved envelope", ()->
          lst.sendChallenge("MOCK_USER",
            propA:"SOMETHING"
          )
          JsMockito.verify(mocks["lib/concurrency/Mutex"].lock)(
            new JsHamcrest.SimpleMatcher(
              matches:(o)->
                o.criticalSection()
                JSON.parse(data[MESSAGE_QUEUE+"::MOCK_USER"])[4].id is "MOCK_GENERATED_ID"
            )
          )
        )
        test("Saved envelope marshalled using marshaller marshalState", ()->
          lst.sendChallenge("MOCK_USER",
            propA:"SOMETHING"
          )
          JsMockito.verify(fakeBuiltMarshaller.marshalState)(
            new JsHamcrest.SimpleMatcher(
              describeTo:(d)->
                d.append("marshaller call")
              matches:(e)->
                e.get("payload")? && e.get("type")?
            )
          )
        )
        test("Saved envelope has issued challenge type", ()->
          lst.sendChallenge("MOCK_USER",
            propA:"SOMETHING"
          )
          chai.assert.equal(CHALLENGE_ISSUED_MESSAGE_TYPE, JSON.parse(data[MESSAGE_ITEM+"::MOCK_GENERATED_ID"]).type)
        )
        test("Saved envelope has game as payload", ()->
          lst.sendChallenge("MOCK_USER",
            propA:"SOMETHING"
          )
          chai.assert.equal("SOMETHING", JSON.parse(data[MESSAGE_ITEM+"::MOCK_GENERATED_ID"]).payload.propA)
        )
        test("Game not defined - does nothing", ()->
          delete data[MESSAGE_ITEM+"::MOCK_GENERATED_ID"]
          lst.sendChallenge("MOCK_USER")
          chai.assert.isUndefined(data[MESSAGE_ITEM+"::MOCK_GENERATED_ID"])
          JsMockito.verify(mocks["lib/concurrency/Mutex"].lock, JsMockito.Verifiers.never())(JsHamcrest.Matchers.anything())
        )
      )
    )
  )


)

