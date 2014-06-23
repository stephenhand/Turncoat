fakeBuiltMarshaller = {}
dispatcher = null

require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("lib/logging/LoggerFactory", "lib/transports/LocalStorageTransport", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      l=
        getLogger:()->
          trace:()->

      l
    )
  )
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
        off:()->
        trigger:()->
      Model:actual.Model
    )
  )
  Isolate.mapAsFactory("underscore", "lib/transports/LocalStorageTransport", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      extend:(extendee, extender)->
        extendee.trigger = extender.trigger
        if !extendee.marshaller? then dispatcher = extendee
    )
  )
  Isolate.mapAsFactory("uuid", "lib/transports/LocalStorageTransport", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      ret=()->
        ret.func()
      ret.func = ()->
        "MOCK_GENERATED_ID"
      ret
    )
  )
)
define(["isolate!lib/transports/LocalStorageTransport", "backbone", "matchers", "operators", "assertThat","jsMockito", "verifiers"], (LocalStorageTransport, Backbone, m, o, a, jm, v)->
  MESSAGE_QUEUE = "message-queue"
  MESSAGE_ITEM = "message-item"
  CHALLENGE_ISSUED_MESSAGE_TYPE = "challenge-issued"
  EVENT_MESSAGE_TYPE = "event"
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
      fakeBuiltMarshaller.unmarshalModel=jm.mockFunction()
      fakeBuiltMarshaller.marshalModel=jm.mockFunction()
      fakeBuiltMarshaller.unmarshalState=jm.mockFunction()
      fakeBuiltMarshaller.marshalState=jm.mockFunction()
      jm.when(fakeBuiltMarshaller.marshalModel)(m.anything()).then((obj)->
        JSON.stringify(obj)
      )
      jm.when(fakeBuiltMarshaller.marshalState)(m.anything()).then((obj)->
        JSON.stringify(obj)
      )
      jm.when(fakeBuiltMarshaller.unmarshalModel)(m.anything()).then((str)->
        new Backbone.Collection(JSON.parse(str))
      )
      jm.when(fakeBuiltMarshaller.unmarshalState)(m.anything()).then((str)->
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
      mocks["lib/concurrency/Mutex"].lock = jm.mockFunction()
      jm.when(mocks["lib/concurrency/Mutex"].lock)(m.func()).then((f)->
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
      mocks["lib/turncoat/Factory"].buildStateMarshaller = jm.mockFunction()
      jm.when(mocks["lib/turncoat/Factory"].buildStateMarshaller)().then(()->
        fakeBuiltMarshaller
      )
      mocks["backbone"].Events.trigger = jm.mockFunction()
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
        mocks["lib/turncoat/Factory"].buildStateMarshaller = jm.mockFunction()
        jm.when(mocks["lib/turncoat/Factory"].buildStateMarshaller)().then(()->
          defaultMarshaller
        )
      )
      test("Sets userId to userId of supplied options", ()->
        newLST = new LocalStorageTransport(userId:"TEST_USER_ID")
        a(newLST.userId, "TEST_USER_ID")
      )
      test("Sets gameId to gameId of supplied options", ()->
        newLST = new LocalStorageTransport(gameId:"TEST_GAME_ID")
        a(newLST.gameId, "TEST_GAME_ID")
      )
      test("No marshaller supplied - builds default marshaller", ()->
        newLST = new LocalStorageTransport()
        jm.verify(mocks["lib/turncoat/Factory"].buildStateMarshaller)()
        a(newLST.marshaller, defaultMarshaller)
      )
      test("Marshaller supplied - uses provided marshaller", ()->
        marshaller = {}
        newLST = new LocalStorageTransport(marshaller:marshaller)
        jm.verify(mocks["lib/turncoat/Factory"].buildStateMarshaller, v.never())()
        a(newLST.marshaller, marshaller)
      )
    )
    suite("startListening", ()->
      setup(()->
        dispatcher.on = jm.mockFunction()
        new LocalStorageTransport()
        dispatcher.on = jm.mockFunction()
        data[MESSAGE_QUEUE+"::MOCK_USER"] = mockUserSingleItemQueue
        lst.trigger = jm.mockFunction()

      )
      test("Empty starting queue - does nothing except load & save empty queue.", ()->

        mocks["lib/concurrency/Mutex"].lock = jm.mockFunction()
        data[MESSAGE_QUEUE+"::MOCK_USER"] = JSON.stringify([])
        lst.startListening()
        setupMarshaller()
        jm.verify(mocks["lib/concurrency/Mutex"].lock)(
          new JsHamcrest.SimpleMatcher(
            describeTo:(d)->d.append("mutext options")
            matches:(o)->
              try
                o.criticalSection()
                jm.verify(fakeBuiltMarshaller.unmarshalModel)(JSON.stringify([]))
                jm.verify(fakeBuiltMarshaller.marshalModel)(m.hasMember("models",m.equivalentArray([])))
                o.success()
                jm.verify(fakeBuiltMarshaller.unmarshalState, v.never())(m.anything())
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
          mocks["lib/concurrency/Mutex"].lock = jm.mockFunction()
          jm.when(mocks["lib/concurrency/Mutex"].lock)(m.anything()).then((o)->
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
          jm.verify(mocks["lib/concurrency/Mutex"].lock, v.times(3))(m.anything())

          jm.verify(fakeBuiltMarshaller.unmarshalModel)(JSON.stringify([
            id:"MOCK_ID1"
          ,
            id:"MOCK_ID2"
          ,
            id:"MOCK_ID3"
          ]))
          jm.verify(fakeBuiltMarshaller.marshalModel)(m.hasMember("models",
            m.allOf(
              m.hasItems(
                m.hasMember("id","MOCK_ID2")
              ,
                m.hasMember("id","MOCK_ID3")
              )
            ,
              m.hasSize(2)
            )
          ))
          jm.verify(fakeBuiltMarshaller.unmarshalState)(items[0])
          jm.verify(fakeBuiltMarshaller.unmarshalModel)(JSON.stringify([
            id:"MOCK_ID2"
          ,
            id:"MOCK_ID3"
          ]))
          jm.verify(fakeBuiltMarshaller.marshalModel)(
            m.hasMember("models",
              m.allOf(
                m.hasItems(
                  m.hasMember("id","MOCK_ID3")
                )
              ,
                m.hasSize(1)
              )
            )
          )
          jm.verify(fakeBuiltMarshaller.unmarshalState)(items[1])
          jm.verify(fakeBuiltMarshaller.unmarshalModel)(JSON.stringify([
            id:"MOCK_ID3"
          ]))
          jm.verify(fakeBuiltMarshaller.marshalModel)(
            m.hasMember("models",
              m.empty()
            )
          )
          jm.verify(fakeBuiltMarshaller.unmarshalState)(items[2])

        )
      )
      test("Binds to dispatcher queueModified event", ()->
        lst.startListening()
        jm.verify(dispatcher.on)("queueModified", m.func())
      )
      test("Binds To LocalStorageChanged Event", ()->
        lst.startListening()
        jm.verify(mocks.jqueryObjects.getSelectorResult(window).on)("storage", m.func())
      )
      test("Multiple calls - only binds to dispatcher queueModified event once", ()->
        lst.startListening()
        lst.startListening()
        lst.startListening()
        lst.startListening()
        jm.verify(dispatcher.on)("queueModified", m.func())
      )
      test("Binds To LocalStorageChanged Event", ()->
        lst.startListening()
        jm.verify(mocks.jqueryObjects.getSelectorResult(window).on)("storage", m.func())
      )
      test("Multiple calls - only binds to LocalStorageChanged Event once", ()->
        lst.startListening()
        lst.startListening()
        lst.startListening()
        lst.startListening()
        jm.verify(mocks.jqueryObjects.getSelectorResult(window).on)("storage", m.func())
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
          jm.verify(mocks.jqueryObjects.getSelectorResult(window).on)(
            "storage",
            new JsHamcrest.SimpleMatcher(
              matches:(f)->
                f(
                  originalEvent:
                    key: MESSAGE_QUEUE+"::A_USER_ID"
                )
                try
                  jm.verify(mocks["lib/concurrency/Mutex"].lock)(
                    new JsHamcrest.SimpleMatcher(
                      describeTo:(d)->
                        d.append("valid criticalSection.")
                      matches:(o)->
                        try

                          a(mockUserSingleItemQueue, data[MESSAGE_QUEUE+"::A_USER_ID"])
                          o.criticalSection()
                          a(JSON.stringify([]), data[MESSAGE_QUEUE+"::A_USER_ID"])
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
          jm.verify(mocks.jqueryObjects.getSelectorResult(window).on)(
            "storage",
            new JsHamcrest.SimpleMatcher(
              matches:(f)->
                f(
                  originalEvent:
                    key: MESSAGE_QUEUE+"::A_USER_ID::A_GAME_ID"
                )
                try
                  jm.verify(mocks["lib/concurrency/Mutex"].lock)(
                    new JsHamcrest.SimpleMatcher(
                      describeTo:(d)->
                        d.append("valid criticalSection.")
                      matches:(o)->
                        try
                          a(mockGameQueue, data[MESSAGE_QUEUE+"::A_USER_ID::A_GAME_ID"])
                          o.criticalSection()
                          a(JSON.stringify([]), data[MESSAGE_QUEUE+"::A_USER_ID::A_GAME_ID"])
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
          dispatcherHandler = jm.mockFunction()
          jm.when(dispatcher.on)("queueModified", m.func()).then(dispatcherHandler)
          lst.startListening()
          mocks["lib/concurrency/Mutex"].lock = jm.mockFunction()
          jm.verify(mocks.jqueryObjects.getSelectorResult(window).on)(
            "storage",
            new JsHamcrest.SimpleMatcher(
              matches:(f)->
                f(
                  originalEvent:
                    key:"NOT_A_MESSAGE_QUEUE::A_USER_ID::A_GAME_ID"
                )
                try

                  jm.verify(mocks["lib/concurrency/Mutex"].lock, v.never())(m.anything())
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
          lst.trigger = jm.mockFunction()
          mocks["lib/concurrency/Mutex"].lock = jm.mockFunction()
          jm.when(mocks["lib/concurrency/Mutex"].lock)(m.func()).then((f)->
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
            jm.verify(dispatcher.on)(
              "queueModified",
              new JsHamcrest.SimpleMatcher(
                describeTo:(d)->
                  d.append("valid queueModified handler.")
                matches:(f)->
                  f(
                    userId:"MOCK_USER"
                  )
                  try
                    jm.verify(mocks["lib/concurrency/Mutex"].lock)(
                      m.allOf(
                        m.hasMember("criticalSection",
                          new JsHamcrest.SimpleMatcher(
                            describeTo:(d)->
                              d.append("valid criticalSection.")
                            matches:(mf)->
                              try
                                a(mockUserSingleItemQueue, data[MESSAGE_QUEUE+"::MOCK_USER"])
                                mf()
                                a(JSON.stringify([]), data[MESSAGE_QUEUE+"::MOCK_USER"])
                                true
                              catch e
                                false

                          )
                        ),
                        m.hasMember("success", m.func())
                      )
                    )
                    true
                  catch e
                    false
              )
            )
          )
          test("Uses marshaller marshalState / unmarshalState", ()->
            jm.verify(dispatcher.on)(
              "queueModified",
              new JsHamcrest.SimpleMatcher(
                describeTo:(d)->
                  d.append("valid queueModified handler.")
                matches:(f)->
                  f(
                    userId:"MOCK_USER"
                  )
                  try
                    jm.verify(mocks["lib/concurrency/Mutex"].lock)(
                      m.hasMember("criticalSection",
                        new JsHamcrest.SimpleMatcher(
                          matches:(mf)->
                            try
                              orig = data[MESSAGE_QUEUE+"::MOCK_USER"]
                              mf()
                              jm.verify(fakeBuiltMarshaller.unmarshalModel)(orig)
                              jm.verify(fakeBuiltMarshaller.marshalModel)(
                                m.hasMember("models",m.equivalentArray([]))
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
            jm.verify(dispatcher.on)(
              "queueModified",
              new JsHamcrest.SimpleMatcher(
                describeTo:(d)->
                  d.append("valid queueModified handler.")
                matches:(f)->
                  f(
                    userId:"MOCK_USER"
                  )
                  try
                    jm.verify(mocks["lib/concurrency/Mutex"].lock)(
                      new JsHamcrest.SimpleMatcher(
                        matches:(o)->
                          try
                            o.criticalSection()
                            jm.verify(fakeBuiltMarshaller.unmarshalModel, v.never())(m.anything())
                            jm.verify(fakeBuiltMarshaller.marshalModel, v.never())(m.anything())
                            o.success()
                            jm.verify(fakeBuiltMarshaller.unmarshalState, v.never())(m.anything())
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
            jm.verify(dispatcher.on)(
              "queueModified",
              new JsHamcrest.SimpleMatcher(
                describeTo:(d)->
                  d.append("valid queueModified handler.")
                matches:(f)->
                  f(
                    userId:"MOCK_USER"
                  )
                  try
                    jm.verify(mocks["lib/concurrency/Mutex"].lock)(
                      new JsHamcrest.SimpleMatcher(
                        matches:(o)->
                          try
                            o.criticalSection()
                            jm.verify(fakeBuiltMarshaller.unmarshalModel)(JSON.stringify([]))
                            jm.verify(fakeBuiltMarshaller.marshalModel)(m.hasMember("models",
                              m.equivalentArray([]))
                            )
                            o.success()
                            jm.verify(fakeBuiltMarshaller.unmarshalState, v.never())(m.anything())
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
            jm.verify(dispatcher.on)(
              "queueModified",
              new JsHamcrest.SimpleMatcher(
                describeTo:(d)->
                  d.append("valid queueModified handler.")
                matches:(f)->
                  f(
                    userId:"MOCK_USER"
                  )
                  try
                    jm.verify(mocks["lib/concurrency/Mutex"].lock)(
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
            jm.verify(dispatcher.on)(
              "queueModified",
              new JsHamcrest.SimpleMatcher(
                describeTo:(d)->
                  d.append("valid queueModified handler.")
                matches:(f)->
                  f(
                    userId:"MOCK_USER"
                  )
                  try
                    jm.verify(mocks["lib/concurrency/Mutex"].lock)(
                      new JsHamcrest.SimpleMatcher(
                        matches:(o)->
                          try
                            payloadData = data[MESSAGE_ITEM+"::MOCK_ID1"]
                            o.criticalSection()
                            o.success()
                            jm.verify(fakeBuiltMarshaller.unmarshalState)(payloadData)
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
            jm.verify(dispatcher.on)(
              "queueModified",
              new JsHamcrest.SimpleMatcher(
                describeTo:(d)->
                  d.append("valid queueModified handler.")
                matches:(f)->
                  f(
                    userId:"MOCK_USER"
                  )
                  try
                    jm.verify(mocks["lib/concurrency/Mutex"].lock)(
                      new JsHamcrest.SimpleMatcher(
                        matches:(o)->
                          try
                            o.criticalSection()
                            o.success()
                            jm.verify(lst.trigger)("challengeReceived",m.hasMember("propA", "SOMETHING"))
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
          test("Envelope has payload and 'Event' type - triggers 'Event Recieved' event from transport with payload", ()->

            data[MESSAGE_ITEM+"::MOCK_ID1"]=JSON.stringify(
              type:EVENT_MESSAGE_TYPE
              payload:
                propA:"SOMETHING"
            )
            jm.verify(dispatcher.on)(
              "queueModified",
              new JsHamcrest.SimpleMatcher(
                describeTo:(d)->
                  d.append("valid queueModified handler.")
                matches:(f)->
                  f(
                    userId:"MOCK_USER"
                  )
                  try
                    jm.verify(mocks["lib/concurrency/Mutex"].lock)(
                      new JsHamcrest.SimpleMatcher(
                        matches:(o)->
                          try
                            o.criticalSection()
                            o.success()
                            jm.verify(lst.trigger)("eventReceived",m.hasMember("propA", "SOMETHING"))
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
            jm.verify(dispatcher.on)(
              "queueModified",
              new JsHamcrest.SimpleMatcher(
                describeTo:(d)->
                  d.append("valid queueModified handler.")
                matches:(f)->
                  f(
                    userId:"MOCK_USER"
                  )
                  try
                    jm.verify(mocks["lib/concurrency/Mutex"].lock)(
                      new JsHamcrest.SimpleMatcher(
                        matches:(o)->
                          try
                            o.criticalSection()
                            o.success()
                            a(data[MESSAGE_ITEM+"::MOCK_ID1"], m.nil())
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
              jm.when(mocks["lib/concurrency/Mutex"].lock)(m.anything()).then((o)->
                try
                  o.criticalSection()
                catch e
                  o.error(e)
                o.success()
              )
            )
            test("Continues dequeue sequence for each message", ()->
              jm.verify(dispatcher.on)(
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
                      jm.verify(mocks["lib/concurrency/Mutex"].lock, v.times(3))(m.anything())

                      jm.verify(fakeBuiltMarshaller.unmarshalModel)(JSON.stringify([
                        id:"MOCK_ID1"
                      ,
                        id:"MOCK_ID2"
                      ,
                        id:"MOCK_ID3"
                      ]))
                      jm.verify(fakeBuiltMarshaller.marshalModel)(m.hasMember("models",
                        m.allOf(
                          m.hasItems(
                            m.hasMember("id","MOCK_ID2")
                          ,
                            m.hasMember("id","MOCK_ID3")
                          )
                        ,
                          m.hasSize(2)
                        ))
                      )
                      jm.verify(fakeBuiltMarshaller.unmarshalState)(items[0])
                      jm.verify(fakeBuiltMarshaller.unmarshalModel)(JSON.stringify([
                        id:"MOCK_ID2"
                      ,
                        id:"MOCK_ID3"
                      ]))
                      jm.verify(fakeBuiltMarshaller.marshalModel)(m.hasMember("models",
                        m.allOf(
                          m.hasItem(
                            m.hasMember("id","MOCK_ID3")
                          )
                        ,
                          m.hasSize(1)
                        )
                      ))
                      jm.verify(fakeBuiltMarshaller.unmarshalState)(items[1])
                      jm.verify(fakeBuiltMarshaller.unmarshalModel)(JSON.stringify([
                        id:"MOCK_ID3"
                      ]))
                      jm.verify(fakeBuiltMarshaller.marshalModel)(m.empty())
                      jm.verify(fakeBuiltMarshaller.unmarshalState)(items[2])
                      true
                    catch e
                      false
                )
              )
            )
            test("Continues dequeue sequence if missing message is hit", ()->
              delete data[MESSAGE_ITEM+"::MOCK_ID2"]
              jm.verify(dispatcher.on)(
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
                      jm.verify(mocks["lib/concurrency/Mutex"].lock, v.times(3))(m.anything())

                      jm.verify(fakeBuiltMarshaller.unmarshalModel)(JSON.stringify([
                        id:"MOCK_ID1"
                      ,
                        id:"MOCK_ID2"
                      ,
                        id:"MOCK_ID3"
                      ]))
                      jm.verify(fakeBuiltMarshaller.marshalModel)(m.hasMember("models",
                        m.allOf(
                          m.hasItems(
                            m.hasMember("id","MOCK_ID2")
                          ,
                            m.hasMember("id","MOCK_ID3")
                          )
                        ,
                          m.hasSize(2)
                        ))
                      )
                      jm.verify(fakeBuiltMarshaller.unmarshalState)(items[0])
                      jm.verify(fakeBuiltMarshaller.unmarshalModel)(JSON.stringify([
                        id:"MOCK_ID2"
                      ,
                        id:"MOCK_ID3"
                      ]))
                      jm.verify(fakeBuiltMarshaller.marshalModel)(m.hasMember("models",
                        m.allOf(
                          m.hasItem(
                            m.hasMember("id","MOCK_ID3")
                          )
                        ,
                          m.hasSize(1)
                        )
                      ))
                      jm.verify(fakeBuiltMarshaller.unmarshalState, v.never())(items[1])
                      jm.verify(fakeBuiltMarshaller.unmarshalModel)(JSON.stringify([
                        id:"MOCK_ID3"
                      ]))
                      jm.verify(fakeBuiltMarshaller.marshalModel)(m.hasMember("models",
                        m.empty()
                      ))
                      jm.verify(fakeBuiltMarshaller.unmarshalState)(items[2])
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
        dispatcher.on = jm.mockFunction()
        dispatcher.off = jm.mockFunction()
        jm.when(dispatcher.on)(m.anything(),m.anything()).then((n, h)->dispatcherHandler=h)
      )
      test("Unbinds dispatcher event", ()->
        lst.startListening()
        lst.stopListening()
        jm.verify(dispatcher.off)("queueModified", dispatcherHandler)
      )
      test("Multiple calls - only unbinds from LocalStorageChanged Event once", ()->
        lst.startListening()
        lst.stopListening()
        lst.stopListening()
        lst.stopListening()
        jm.verify(dispatcher.off)("queueModified", dispatcherHandler)
      )
      test("Calls without prior start listening - does nothing", ()->
        lst.stopListening()
        jm.verify(dispatcher.off, v.never())("queueModified", m.func())
      )
      test("Multiple start and stoplistening calls -LocalStorageChanged Event only binds and unbinds when listening state toggles", ()->
        lst.startListening()
        jm.verify(dispatcher.on)("queueModified", dispatcherHandler)
        lst.stopListening()
        jm.verify(dispatcher.off)("queueModified", dispatcherHandler)
        lst.stopListening()
        lst.startListening()
        jm.verify(dispatcher.on)("queueModified", dispatcherHandler)
        lst.startListening()
        lst.startListening()
        lst.stopListening()
        jm.verify(dispatcher.off)("queueModified", dispatcherHandler)
        lst.startListening()
        jm.verify(dispatcher.on)("queueModified", dispatcherHandler)
        lst.stopListening()
        jm.verify(dispatcher.off)("queueModified", dispatcherHandler)
        lst.stopListening()
      )
      test("Unbinds To LocalStorageChanged Event", ()->
        lst.startListening()
        lst.stopListening()
        jm.verify(mocks.jqueryObjects.getSelectorResult(window).off)("storage", mocks.jqueryObjects.methodCallbacks.on["storage"])
      )
      test("Multiple calls - only unbinds from LocalStorageChanged Event once", ()->
        lst.startListening()
        lst.stopListening()
        lst.stopListening()
        lst.stopListening()
        jm.verify(mocks.jqueryObjects.getSelectorResult(window).off)("storage", mocks.jqueryObjects.methodCallbacks.on["storage"])
      )
      test("Calls without prior start listening - does nothing", ()->
        mocks.jqueryObjects
        mocks.jqueryObjects.setSelectorResult(
          off:jm.mockFunction()
        ,window)
        lst.stopListening()
        jm.verify(mocks.jqueryObjects.getSelectorResult(window).off, v.never())("storage", m.func())
      )
      test("Multiple start and stoplistening calls -LocalStorageChanged Event only binds and unbinds when listening state toggles", ()->
        lst.startListening()
        jm.verify(mocks.jqueryObjects.getSelectorResult(window).on)("storage", m.func())
        lst.stopListening()
        jm.verify(mocks.jqueryObjects.getSelectorResult(window).off)("storage", mocks.jqueryObjects.methodCallbacks.on["storage"])
        lst.stopListening()
        lst.startListening()
        jm.verify(mocks.jqueryObjects.getSelectorResult(window).on, v.times(2))("storage", m.func())
        lst.startListening()
        lst.startListening()
        lst.stopListening()
        jm.verify(mocks.jqueryObjects.getSelectorResult(window).off)("storage", mocks.jqueryObjects.methodCallbacks.on["storage"])
        lst.startListening()
        jm.verify(mocks.jqueryObjects.getSelectorResult(window).on, v.times(3))("storage", m.func())
        lst.stopListening()
        jm.verify(mocks.jqueryObjects.getSelectorResult(window).off)("storage", mocks.jqueryObjects.methodCallbacks.on["storage"])
        lst.stopListening()
      )
    )
    suite("sendChallenge", ()->
      setup(()->
        dispatcher.trigger = jm.mockFunction()
      )
      test("No existing target user queue - creates queue in mutex",()->
        delete data[MESSAGE_QUEUE+"::MOCK_USER"]
        lst.sendChallenge("MOCK_USER", {})
        jm.verify(mocks["lib/concurrency/Mutex"].lock)(
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
        jm.verify(mocks["lib/concurrency/Mutex"].lock)(
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
          jm.verify(mocks["lib/concurrency/Mutex"].lock)(
            new JsHamcrest.SimpleMatcher(
              matches:(o)->
                o.criticalSection()
                JSON.parse(data[MESSAGE_QUEUE+"::MOCK_USER"]).length is existing+1
            )
          )
        )
        test("Generates ID and saves data to local storage location based on it before entering critical section", ()->
          lst.sendChallenge("MOCK_USER",
            propA:"SOMETHING"
          )
          a(data[MESSAGE_ITEM+"::MOCK_GENERATED_ID"])
        )
        test("Queued ID matches id of saved envelope", ()->
          lst.sendChallenge("MOCK_USER",
            propA:"SOMETHING"
          )
          jm.verify(mocks["lib/concurrency/Mutex"].lock)(
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
          jm.verify(fakeBuiltMarshaller.marshalState)(
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
          a(CHALLENGE_ISSUED_MESSAGE_TYPE, JSON.parse(data[MESSAGE_ITEM+"::MOCK_GENERATED_ID"]).type)
        )
        test("Saved envelope has game as payload", ()->
          lst.sendChallenge("MOCK_USER",
            propA:"SOMETHING"
          )
          a("SOMETHING", JSON.parse(data[MESSAGE_ITEM+"::MOCK_GENERATED_ID"]).payload.propA)
        )
        test("Triggers queueModified event with userId and gameId as nothing.", ()->
          lst.sendChallenge("MOCK_USER",
            propA:"SOMETHING"
          )
          jm.verify(mocks["lib/concurrency/Mutex"].lock)(
            new JsHamcrest.SimpleMatcher(
              matches:(o)->
                o.criticalSection()
                try
                  jm.verify(dispatcher.trigger)("queueModified", m.allOf(
                    m.hasMember("userId","MOCK_USER")
                    m.hasMember("gameId",m.nil())
                  ))
                  true
                catch e
                  false
            )
          )
        )
        test("Game not defined - does nothing", ()->
          delete data[MESSAGE_ITEM+"::MOCK_GENERATED_ID"]
          lst.sendChallenge("MOCK_USER")
          a(data[MESSAGE_ITEM+"::MOCK_GENERATED_ID"], m.nil())
          jm.verify(mocks["lib/concurrency/Mutex"].lock, v.never())(m.anything())
        )
      )
    )
    suite("broadcastGameEvent", ()->
      messagedata = null
      recipients = null
      counter = 0
      setup(()->
        dispatcher.trigger = jm.mockFunction()
        lst.gameId = "GAME_ID"
        counter = 0
        mocks["uuid"].func = ()->
          "MOCK_GENERATED_ID_"+(counter++)
        messagedata = "SOME DATA"
        recipients = [
          "RECIPIENT_1",
          "RECIPIENT_2",
          "RECIPIENT_3",
        ]
      )
      teardown(()->
        delete data[MESSAGE_ITEM+"::MOCK_GENERATED_ID_0"]
        delete data[MESSAGE_ITEM+"::MOCK_GENERATED_ID_1"]
        delete data[MESSAGE_ITEM+"::MOCK_GENERATED_ID_2"]
      )
      test("Game Id not set on transport - throws", ()->
        lst.gameId = null
        a(
          ()->
            lst.broadcastGameEvent("MOCK_USER", messagedata)
        ,
          m.raisesAnything()
        )
      )
      test("Recipients not defined - does nothing", ()->
        lst.broadcastGameEvent(null, messagedata)
        a(data[MESSAGE_ITEM+"::MOCK_GENERATED_ID_0"], m.nil())
        jm.verify(mocks["lib/concurrency/Mutex"].lock, v.never())(m.anything())
      )
      test("Data not defined - does nothing", ()->
        lst.broadcastGameEvent("MOCK_USER")
        a(data[MESSAGE_ITEM+"::MOCK_GENERATED_ID_0"], m.nil())
        jm.verify(mocks["lib/concurrency/Mutex"].lock, v.never())(m.anything())
      )
      suite("Single recipient", ()->
        test("Creates single message item containing messagedata", ()->
          lst.broadcastGameEvent(["RECIPIENT_1"], messagedata)
          a(data[MESSAGE_ITEM+"::MOCK_GENERATED_ID_0"])
          a(data[MESSAGE_ITEM+"::MOCK_GENERATED_ID_1"], m.nil())
        )
        test("Message item type is event", ()->
          lst.broadcastGameEvent(["RECIPIENT_1"], messagedata)
          a(JSON.parse(data[MESSAGE_ITEM+"::MOCK_GENERATED_ID_0"]).type, EVENT_MESSAGE_TYPE)
        )
        test("Message item payload is supplied event data", ()->
          lst.broadcastGameEvent(["RECIPIENT_1"], messagedata)
          a(JSON.parse(data[MESSAGE_ITEM+"::MOCK_GENERATED_ID_0"]).payload, "SOME DATA")
        )
        test("Queues message with id for recipient/game combination", ()->
          lst.broadcastGameEvent(["RECIPIENT_1"], messagedata)
          jm.verify(mocks["lib/concurrency/Mutex"].lock)(
            new JsHamcrest.SimpleMatcher(
              describeTo:(d)->
                d.append("mutex lock")
              matches:(o)->
                o.criticalSection()
                JSON.parse(data[MESSAGE_QUEUE+"::RECIPIENT_1::GAME_ID"]).length is 1
                JSON.parse(data[MESSAGE_QUEUE+"::RECIPIENT_1::GAME_ID"])[0].id is "MOCK_GENERATED_ID_0"
            )

          )
        )
      )
      suite("Multiple recipients", ()->
        test("Creates message item per recipient with same content", ()->
          lst.broadcastGameEvent(recipients, messagedata)
          a(data[MESSAGE_ITEM+"::MOCK_GENERATED_ID_0"])
          a(data[MESSAGE_ITEM+"::MOCK_GENERATED_ID_1"])
          a(data[MESSAGE_ITEM+"::MOCK_GENERATED_ID_2"])
          a(data[MESSAGE_ITEM+"::MOCK_GENERATED_ID_3"], m.nil())
          a(JSON.parse(data[MESSAGE_ITEM+"::MOCK_GENERATED_ID_0"]).type, EVENT_MESSAGE_TYPE)
          a(JSON.parse(data[MESSAGE_ITEM+"::MOCK_GENERATED_ID_1"]).type, EVENT_MESSAGE_TYPE)
          a(JSON.parse(data[MESSAGE_ITEM+"::MOCK_GENERATED_ID_2"]).type, EVENT_MESSAGE_TYPE)
          a(JSON.parse(data[MESSAGE_ITEM+"::MOCK_GENERATED_ID_0"]).payload, "SOME DATA")
          a(JSON.parse(data[MESSAGE_ITEM+"::MOCK_GENERATED_ID_1"]).payload, "SOME DATA")
          a(JSON.parse(data[MESSAGE_ITEM+"::MOCK_GENERATED_ID_2"]).payload, "SOME DATA")
        )
        test("Queues messages with id for each recipient/game", ()->
          lst.broadcastGameEvent(recipients, messagedata)
          i = 0
          jm.verify(mocks["lib/concurrency/Mutex"].lock,v.times(3))(
            new JsHamcrest.SimpleMatcher(
              describeTo:(d)->
                d.append("mutex lock")
              matches:(o)->
                o.criticalSection()
                i++
                switch i
                  when 1
                    JSON.parse(data[MESSAGE_QUEUE+"::RECIPIENT_1::GAME_ID"]).length is 1 and JSON.parse(data[MESSAGE_QUEUE+"::RECIPIENT_1::GAME_ID"])[0].id is "MOCK_GENERATED_ID_0"
                  when 2
                    JSON.parse(data[MESSAGE_QUEUE+"::RECIPIENT_2::GAME_ID"]).length is 1 and JSON.parse(data[MESSAGE_QUEUE+"::RECIPIENT_2::GAME_ID"])[0].id is "MOCK_GENERATED_ID_1"
                  when 3
                    JSON.parse(data[MESSAGE_QUEUE+"::RECIPIENT_3::GAME_ID"]).length is 1 and JSON.parse(data[MESSAGE_QUEUE+"::RECIPIENT_3::GAME_ID"])[0].id is "MOCK_GENERATED_ID_2"
            )

          )
        )
        test("Triggers queueModified event with userId and gameId for each recipient.", ()->
          mocks["backbone"].Events.trigger = jm.mockFunction()
          lst.broadcastGameEvent(recipients, messagedata)

          jm.verify(mocks["lib/concurrency/Mutex"].lock)(
            new JsHamcrest.SimpleMatcher(
              describeTo:(d)->
                d.append("mutex lock")
              matches:(o)->
                o.criticalSection()
                try
                  jm.verify(dispatcher.trigger)("queueModified", m.allOf(
                    m.hasMember("userId","RECIPIENT_1")
                    m.hasMember("gameId","GAME_ID")
                  ))
                  jm.verify(dispatcher.trigger)("queueModified", m.allOf(
                    m.hasMember("userId","RECIPIENT_2")
                    m.hasMember("gameId","GAME_ID")
                  ))
                  jm.verify(dispatcher.trigger)("queueModified", m.allOf(
                    m.hasMember("userId","RECIPIENT_3")
                    m.hasMember("gameId","GAME_ID")
                  ))
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

