
require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("lib/concurrency/Mutex", "lib/transports/LocalStorageTransport", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      m=
        lock:JsMockito.mockFunction()

      m
    )
  )
)
define(["isolate!lib/transports/LocalStorageTransport"], (LocalStorageTransport)->
  mocks = window.mockLibrary["lib/transports/LocalStorageTransport"]

  suite("LocalStorageTransportTest", ()->
    lst= null
    origGet = Storage.prototype.getItem
    origSet = Storage.prototype.setItem
    origRemove = Storage.prototype.removeItem
    origClear = Storage.prototype.clear
    setup(()->

      JsMockito.when(mocks["lib/concurrency/Mutex"].lock)(JsHamcrest.Matchers.func()).then((f)->
        f()
      )
      data=[]
      Storage.prototype.getItem=(key)->
        data[key]
      Storage.prototype.setItem=(key, val)->
        data[key]=val
      Storage.prototype.removeItem= (key)->
        delete data[key]
      Storage.prototype.clear = ()->
        data=[]
      lst = new LocalStorageTransport()

    )
    teardown(()->
      mocks.jqueryObjects.reset()
    )
    suite("startListening", ()->
      test("Binds To LocalStorageChanged Event", ()->
        lst.startListening()
        JsMockito.verify(mocks.jqueryObjects.getSelectorResult(window).on("storage", JsHamcrest.Matchers.func()))
      )
      test("Multiple calls - only binds to LocalStorageChanged Event once", ()->
        lst.startListening()
        lst.startListening()
        lst.startListening()
        lst.startListening()
        JsMockito.verify(mocks.jqueryObjects.getSelectorResult(window).on("storage", JsHamcrest.Matchers.func()))
      )
      suite("LocalStorageChanged event handler", ()->)
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

