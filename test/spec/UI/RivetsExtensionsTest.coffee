require(["isolate","isolateHelper"], (Isolate, Helper)->

  Isolate.mapAsFactory("rivets","UI/RivetsExtensions", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      stubRivets =
        binders:{}
        formatters:{}
      stubRivets
    )
  )
  Isolate.mapAsFactory("sprintf","UI/RivetsExtensions", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      ret = ()->
        ret.func.apply(ret, arguments)
      ret.func = actual
      ret
    )
  )
)

define(['isolate!UI/RivetsExtensions', "matchers", "operators", "assertThat","jsMockito", "verifiers"], (RivetsExtensions, m, o, a, jm, v)->
  mocks=window.mockLibrary['UI/RivetsExtensions']
  suite("RivetsExtensions", ()->
    setup(()->
      mocks.jqueryObjects = []
      delete RivetsExtensions.binders.previousClass
    )
    suite("binders", ()->
      suite("style_top", ()->
        test("setsStyleTopOnElement", ()->
          mockEle =
            style:
              top:"UNSET"
          RivetsExtensions.binders.style_top(mockEle, "MOCK_VALUE")
          a(mockEle.style.top, "MOCK_VALUE")
        )
        test("throwsForInvalidElement", ()->
          mockEle ={}
          a(()->
            RivetsExtensions.binders.style_top(mockEle, "MOCK_VALUE")
          ,
            m.raisesAnything())
        )
      )
      suite("style_left", ()->
        test("setsStyleLeftOnElement", ()->
          mockEle =
            style:
              left:"UNSET"
          RivetsExtensions.binders.style_left(mockEle, "MOCK_VALUE")
          a(mockEle.style.left, "MOCK_VALUE")
        )
        test("throwsForInvalidElement", ()->
          mockEle ={}
          a(()->
            RivetsExtensions.binders.style_left(mockEle, "MOCK_VALUE")
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
          RivetsExtensions.binders.style_transform(mockEle, "MOCK_VALUE")
          a(mockEle.style.transform, "MOCK_VALUE")
        )
        test("setsStyleWebKitTransformOnElement", ()->
          mockEle =
            style:
              left:"UNSET"
          RivetsExtensions.binders.style_transform(mockEle, "MOCK_VALUE")
          a(mockEle.style.webkitTransform, "MOCK_VALUE")
        )
        test("setsStyleMSTransformOnElement", ()->
          mockEle =
            style:
              left:"UNSET"
          RivetsExtensions.binders.style_transform(mockEle, "MOCK_VALUE")
          a(mockEle.style.msTransform, "MOCK_VALUE")
        )
        test("throwsForInvalidElement", ()->
          mockEle ={}
          a(()->
            RivetsExtensions.binders.style_transform(mockEle, "MOCK_VALUE")
          ,
            m.raisesAnything()
          )
        )
      )
      suite("classappend",()->
        test("Calls JQ toggleClass on element with true", ()->
          mockEle ={}
          RivetsExtensions.binders.classappend(mockEle,"MOCK_CLASS")
          jm.verify(mocks.jqueryObjects[mockEle].toggleClass)("MOCK_CLASS",true)
        )
        test("Subsequent calls on same binder - calls JQ toggleClass using previously appended class on element with false", ()->
          mockEle ={}
          RivetsExtensions.binders.classappend(mockEle,"MOCK_CLASS")
          RivetsExtensions.binders.classappend(mockEle,"MOCK_CLASS_NEXT")
          jm.verify(mocks.jqueryObjects[mockEle].toggleClass)("MOCK_CLASS",false)
          RivetsExtensions.binders.classappend(mockEle,"MOCK_CLASS")
          jm.verify(mocks.jqueryObjects[mockEle].toggleClass)("MOCK_CLASS_NEXT",false)
          RivetsExtensions.binders.classappend(mockEle,"MOCK_CLASS_ANOTHER")
          jm.verify(mocks.jqueryObjects[mockEle].toggleClass, v.times(2))("MOCK_CLASS",false)
        )
      )
    )
    suite("formatters", ()->
      suite("rotateCss", ()->
        test("formatsStringInputAsCssRotateDegrees", ()->
          a(RivetsExtensions.formatters.rotateCss("MOCK_VALUE"),"rotate(MOCK_VALUEdeg)")
        )
        test("formatsIntegerInputAsCssRotateDegrees", ()->
          a(RivetsExtensions.formatters.rotateCss(123),"rotate(123deg)")

        )
        test("formatsFloatingPointInputAsCssRotateDegrees", ()->
          a(RivetsExtensions.formatters.rotateCss(1.23),"rotate(1.23deg)")

        )
        test("formatsFloatingPointInputLosesTrailingZeros", ()->
          a(RivetsExtensions.formatters.rotateCss(1.2300),"rotate(1.23deg)")

        )
        test("usesValueOfInComplexObject", ()->
          a(RivetsExtensions.formatters.rotateCss(
            a:
              b:{}
            c:9
            valueOf:()->"VALUEOF_VAL"
          ),"rotate(VALUEOF_VALdeg)")
        )


      )
      suite("toggle", ()->
        test("toggle undefined and value undefined returns undefined", ()->
          a(RivetsExtensions.formatters.toggle(), m.nil())
        )
        test("toggle false value undefined returns undefined", ()->
          a(RivetsExtensions.formatters.toggle(false), m.nil())
        )
        test("toggleFalseValueDefinedReturnsUndefined", ()->
          a(RivetsExtensions.formatters.toggle(false,"MOCK_VALUE"), m.nil())
        )
        test("Input TrueValueUndefinedReturnsUndefined", ()->
          a(RivetsExtensions.formatters.toggle(true), m.nil())
        )
        test("Input TrueValueStringReturnsValue", ()->
          a(RivetsExtensions.formatters.toggle(true,"MOCK_VALUE"),"MOCK_VALUE")
        )
        test("toggleTrueValueObjectReturnsValue", ()->
          val={}
          a(RivetsExtensions.formatters.toggle(true,val),val)
        )
        test("toggleObjectValueUndefinedReturnsUndefined", ()->
          a(RivetsExtensions.formatters.toggle({}), m.nil())
        )
        test("toggleObjectValueStringReturnsValue", ()->
          a(RivetsExtensions.formatters.toggle({},"MOCK_VALUE"),"MOCK_VALUE")
        )
        test("toggleObjectValueObjectReturnsValue", ()->
          val={}
          a(RivetsExtensions.formatters.toggle({},val),val)
        )
        test("Input false and false value set - returns false value", ()->
          a(RivetsExtensions.formatters.toggle(false, "MOCK TRUE", "MOCK FALSE"),"MOCK FALSE")
        )
        test("Input true and only false value set - returns undefined", ()->
          a(RivetsExtensions.formatters.toggle(true, undefined,"MOCK_VALUE"), m.nil())
        )
      )
      suite("sprintf",()->
        origSPF = null
        setup(()->
          origSPF = mocks["sprintf"].func
          mocks["sprintf"].func=jm.mockFunction()
          JsMockito.when(mocks["sprintf"].func)(m.anything(),m.anything()).then(
            (a,b)->
              mask:a
              value:b
          )
        )
        teardown(()->
          origSPF = mocks["sprintf"].func = origSPF
        )
        test("Calls sprintf with first parameter as value and second parameter as pattern",()->
          ret = RivetsExtensions.formatters.sprintf("MOCK_VALUE","MOCK_MASK")
          a(ret.mask,"MOCK_MASK")
          a(ret.value,"MOCK_VALUE")
        )
      )
      suite("calc",()->
        test("throws if input is not parsable as a float",()->
          a(()->
            RivetsExtensions.formatters.calc("MOCK_VALUE","MOCK_MASK%d")
          ,
            m.raisesAnything()
          )
        )
        test("throws if input is not defined",()->
          a(()->
            RivetsExtensions.formatters.calc(null,"%d*5")
          ,
            m.raisesAnything()
          )
        )
        test("return unmodified input if mask is not defined",()->
          a(RivetsExtensions.formatters.calc(13),13)
        )
        test("substitutes input into mask using sprintf then returns result of expression",()->
          a(RivetsExtensions.formatters.calc(3,"%d*5"),15)
        )
        test("allows Javascript method calls",()->
          a(RivetsExtensions.formatters.calc(3.123,"Math.floor(%d)"),3)
        )
        test("throws if invalid Javascript used in expression",()->
          a(()->
            RivetsExtensions.formatters.calc(13, "Matth.bugaboo(%d)")
          ,
            m.raisesAnything()
          )
        )
        test("allows input not to be used",()->
          a(RivetsExtensions.formatters.calc(3.123,"100/2"),50)
        )
        test("allows non numeric return types",()->
          a(RivetsExtensions.formatters.calc(3.123,"(100/2)+'hello'"),"50hello")
        )
      )
      suite("multiplier",()->
        origSPF = null
        setup(()->
          origSPF = mocks["sprintf"].func
          mocks["sprintf"].func=jm.mockFunction()
          JsMockito.when(mocks["sprintf"].func)(m.anything(),m.anything()).then(
            (a,b)->
              mask:a
              value:b
          )
        )
        teardown(()->
          origSPF = mocks["sprintf"].func = origSPF
        )
        test("decimalInputdecimalMultiplierNoMask_ReturnsMultiplied",()->
          ret = RivetsExtensions.formatters.multiplier("3.5", "2.5")
          a(ret,"8.75")
        )
        test("IntegerInputIntegerMultiplierNoMask_ReturnsMultiplied",()->
          ret = RivetsExtensions.formatters.multiplier("9","5")
          a(ret, "45")
        )
        test("decimalInputdecimalMultiplierMaskSetMask_ReturnsSPrintfResultUsingMultipliedWithMask",()->
          ret = RivetsExtensions.formatters.multiplier("3.5", "2.5" ,"MOCK_MASK")
          a(ret.mask,"MOCK_MASK")
          a(ret.value,"8.75")
        )
        test("NonNumericInputNoMask_ReturnsUnmodifiedInput",()->
          ret = RivetsExtensions.formatters.multiplier("NOT A NUMBER", "2.5" )
          a(ret,"NOT A NUMBER")
        )
        test("NonNumericMultiplierNoMask_ReturnsUnmodifiedInput",()->
          ret = RivetsExtensions.formatters.multiplier("2.5", "NOT A NUMBER")
          a(ret,"2.5")
        )
        test("NonNumericInputWithMask_ReturnsSPreintfResultUsingUnmodifiedInputdWithMask",()->
          ret = RivetsExtensions.formatters.multiplier("NOT A NUMBER", "2.5" ,"MOCK_MASK")
          a(ret.mask,"MOCK_MASK")
          a(ret.value,"NOT A NUMBER")
        )
        test("NonNumericInputWithMask_ReturnsSPreintfResultUsingUnmodifiedInputdWithMask",()->
          ret = RivetsExtensions.formatters.multiplier("2.5","NOT A NUMBER" ,"MOCK_MASK")
          a(ret.mask,"MOCK_MASK")
          a(ret.value,"2.5")
        )
      )

      suite("centroid", ()->
        input = null
        setup(()->
          input = new Backbone.Model()
        )
        suite("Input is backbone model with both attributes set", ()->
          test("Dimension  set as value - retuns position supplied minus half dimention", ()->
            input.set(
              MOCK_POS:10
              MOCK_DIM:2
            )
            a(RivetsExtensions.formatters.centroid(input, "MOCK_POS","MOCK_DIM"), 9)
          )
          test("Dimension set as zero - returns position supplied", ()->
            input.set(
              MOCK_POS:10
              MOCK_DIM:0
            )
            a(RivetsExtensions.formatters.centroid(input, "MOCK_POS","MOCK_DIM"), 10)
          )
          test("Dimension set as negative - returns position supplied plus half negative dimension", ()->
            input.set(
              MOCK_POS:10
              MOCK_DIM:-2
            )
            a(RivetsExtensions.formatters.centroid(input, "MOCK_POS","MOCK_DIM"), 11)
          )
          test("Dimension not set - throws", ()->
            input.set(
              "MOCK_POS":10
            )
            a(
              ()->RivetsExtensions.formatters.centroid(input, "MOCK_POS","MOCK_DIM")
            ,
              m.raisesAnything())
          )
          test("Dimension not numeric - throws", ()->
            input.set(
              "MOCK_POS":10
              "MOCK_DIM":"NOT A NUMBER"
            )
            a(
              ()->RivetsExtensions.formatters.centroid(input, "MOCK_POS","MOCK_DIM")
            ,
              m.raisesAnything())
          )
          test("Dimension converts to numeric - converts", ()->
            input.set(
              MOCK_POS:10
              MOCK_DIM:"-3"
            )
            a(RivetsExtensions.formatters.centroid(input, "MOCK_POS","MOCK_DIM"), 11.5)
          )
          test("Position undefined - throws", ()->
            input.set(
              MOCK_DIM:2
            )
            a(
              ()->RivetsExtensions.formatters.centroid(input, "MOCK_POS","MOCK_DIM")
            ,
              m.raisesAnything())
          )
          test("Position not numeric - throws", ()->
            input.set(
              MOCK_POS:"NOT A NUMBER"
              MOCK_DIM:2
            )
            a(
              ()->RivetsExtensions.formatters.centroid(input, "MOCK_POS","MOCK_DIM")
            ,
              m.raisesAnything())
          )
          test("Position converts to numeric - converts", ()->
            input.set(
              MOCK_POS:"12.5"
              MOCK_DIM:2
            )
            a(RivetsExtensions.formatters.centroid(input, "MOCK_POS","MOCK_DIM"), 11.5)
          )
          test("Position and Dimension converts to numeric - converts", ()->
            input.set(
              MOCK_POS:"12.5"
              MOCK_DIM:"2"
            )
            a(RivetsExtensions.formatters.centroid(input, "MOCK_POS","MOCK_DIM"), 11.5)
          )
        )
        test("Position not set - throws", ()->
          input.set(
            MOCK_POS:10
            MOCK_DIM:2
          )
          a(
            ()->RivetsExtensions.formatters.centroid(input, undefined,"MOCK_DIM")
          ,
            m.raisesAnything())
        )
        test("Position attribute not on input model - throws", ()->
          input.set(
            NOT_MOCK_POS:10
            MOCK_DIM:2
          )
          a(
            ()->RivetsExtensions.formatters.centroid(input, "MOCK_POS","MOCK_DIM")
          ,
            m.raisesAnything())
        )
        test("Dimension not set - throws", ()->
          input.set(
            MOCK_POS:10
            MOCK_DIM:2
          )
          a(
            ()->RivetsExtensions.formatters.centroid(input, "MOCK_POS")
          ,
            m.raisesAnything())
        )
        test("Dimension attribute not on input model - throws", ()->
          input.set(
            MOCK_POS:10
            NOT_MOCK_DIM:2
          )
          a(
            ()->RivetsExtensions.formatters.centroid(input, "MOCK_POS","MOCK_DIM")
          ,
            m.raisesAnything())
        )
      )
    )
  )

)

