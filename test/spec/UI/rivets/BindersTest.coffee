require(["isolate", "isolateHelper"], (Isolate, Helper)->

  Isolate.mapAsFactory("rivets","UI/rivets/Binders", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      stubRivets =
        binders:{}
        formatters:{}
        config:
          adapter:
            read:JsMockito.mockFunction()
      JsMockito.when(stubRivets.config.adapter.read)(JsHamcrest.Matchers.anything(),JsHamcrest.Matchers.anything()).then((obj, key)->
        obj[key]
      )

      stubRivets
    )
  )
  Isolate.mapAsFactory("sprintf","UI/rivets/Binders", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      ret = ()->
        ret.func.apply(ret, arguments)
      ret.func = actual
      ret
    )
  )
)

define(["isolate!UI/rivets/Binders", "matchers", "operators", "assertThat", "jsMockito", "verifiers"],
(Binders, m, o, a, jm, v)->
  mocks = window.mockLibrary["UI/rivets/Binders"]
  suite("Binders", ()->
    setup(()->
      mocks.jqueryObjects = []
      delete Binders.previousClass
    )
    suite("style_top", ()->
      test("setsStyleTopOnElement", ()->
        mockEle =
          style:
            top:"UNSET"
        Binders.style_top(mockEle, "MOCK_VALUE")
        a(mockEle.style.top, "MOCK_VALUE")
      )
      test("throwsForInvalidElement", ()->
        mockEle ={}
        a(()->
          Binders.style_top(mockEle, "MOCK_VALUE")
        ,
          m.raisesAnything())
      )
    )
    suite("style_left", ()->
      test("setsStyleLeftOnElement", ()->
        mockEle =
          style:
            left:"UNSET"
        Binders.style_left(mockEle, "MOCK_VALUE")
        a(mockEle.style.left, "MOCK_VALUE")
      )
      test("throwsForInvalidElement", ()->
        mockEle ={}
        a(()->
          Binders.style_left(mockEle, "MOCK_VALUE")
        ,
          m.raisesAnything()
        )
      )
    )
    suite("style_transform", ()->
      test("setsStyleTransformOnElement", ()->
        mockEle =
          style:
            left:"UNSET"
        Binders.style_transform(mockEle, "MOCK_VALUE")
        a(mockEle.style.transform, "MOCK_VALUE")
      )
      test("setsStyleWebKitTransformOnElement", ()->
        mockEle =
          style:
            left:"UNSET"
        Binders.style_transform(mockEle, "MOCK_VALUE")
        a(mockEle.style.webkitTransform, "MOCK_VALUE")
      )
      test("setsStyleMSTransformOnElement", ()->
        mockEle =
          style:
            left:"UNSET"
        Binders.style_transform(mockEle, "MOCK_VALUE")
        a(mockEle.style.msTransform, "MOCK_VALUE")
      )
      test("throwsForInvalidElement", ()->
        mockEle ={}
        a(()->
          Binders.style_transform(mockEle, "MOCK_VALUE")
        ,
          m.raisesAnything()
        )
      )
    )
    suite("classappend",()->
      test("Calls JQ toggleClass on element with true", ()->
        mockEle ={}
        Binders.classappend(mockEle,"MOCK_CLASS")
        jm.verify(mocks.jqueryObjects[mockEle].toggleClass)("MOCK_CLASS",true)
      )
      test("Subsequent calls on same binder - calls JQ toggleClass using previously appended class on element with false", ()->
        mockEle ={}
        Binders.classappend(mockEle,"MOCK_CLASS")
        Binders.classappend(mockEle,"MOCK_CLASS_NEXT")
        jm.verify(mocks.jqueryObjects[mockEle].toggleClass)("MOCK_CLASS",false)
        Binders.classappend(mockEle,"MOCK_CLASS")
        jm.verify(mocks.jqueryObjects[mockEle].toggleClass)("MOCK_CLASS_NEXT",false)
        Binders.classappend(mockEle,"MOCK_CLASS_ANOTHER")
        jm.verify(mocks.jqueryObjects[mockEle].toggleClass, v.times(2))("MOCK_CLASS",false)
      )
    )
  )
)

