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
      spf=JsMockito.mockFunction()
      JsMockito.when(spf)(JsHamcrest.Matchers.anything(),JsHamcrest.Matchers.anything()).then(
        (a,b)->
          {
          mask:a
          value:b
          }
      )
      spf
    )
  )
)

define(['isolate!UI/RivetsExtensions', "jsMockito", "jsHamcrest", "chai"], (RivetsExtensions, jm, h, c)->
  m = h.Matchers
  a = c.assert
  v = jm.Verifiers
  mocks=window.mockLibrary['UI/RivetsExtensions']
  suite("RivetsExtensions", ()->
    suite("binders", ()->
      suite("style_top", ()->
        test("setsStyleTopOnElement", ()->
          mockEle =
            style:
              top:"UNSET"
          RivetsExtensions.binders.style_top(mockEle, "MOCK_VALUE")
          a.equal(mockEle.style.top, "MOCK_VALUE")
        )
        test("throwsForInvalidElement", ()->
          mockEle ={}
          a.throws(()->
            RivetsExtensions.binders.style_top(mockEle, "MOCK_VALUE")
          )
        )
      )
      suite("style_left", ()->
        test("setsStyleLeftOnElement", ()->
          mockEle =
            style:
              left:"UNSET"
          RivetsExtensions.binders.style_left(mockEle, "MOCK_VALUE")
          a.equal(mockEle.style.left, "MOCK_VALUE")
        )
        test("throwsForInvalidElement", ()->
          mockEle ={}
          a.throws(()->
            RivetsExtensions.binders.style_left(mockEle, "MOCK_VALUE")
          )
        )
      )
      suite("style_transform", ()->
        test("setsStyleTransformOnElement", ()->
          mockEle =
            style:
              left:"UNSET"
          RivetsExtensions.binders.style_transform(mockEle, "MOCK_VALUE")
          a.equal(mockEle.style.transform, "MOCK_VALUE")
        )
        test("setsStyleWebKitTransformOnElement", ()->
          mockEle =
            style:
              left:"UNSET"
          RivetsExtensions.binders.style_transform(mockEle, "MOCK_VALUE")
          a.equal(mockEle.style.webkitTransform, "MOCK_VALUE")
        )
        test("setsStyleMSTransformOnElement", ()->
          mockEle =
            style:
              left:"UNSET"
          RivetsExtensions.binders.style_transform(mockEle, "MOCK_VALUE")
          a.equal(mockEle.style.msTransform, "MOCK_VALUE")
        )
        test("throwsForInvalidElement", ()->
          mockEle ={}
          a.throws(()->
            RivetsExtensions.binders.style_transform(mockEle, "MOCK_VALUE")
          )
        )
      )
      suite("classappend",()->
        test("Calls JQ toggleClass on element with true", ()->
          mockEle ={}
          RivetsExtensions.binders.classappend(mockEle,"MOCK_CLASS")
          mocks.jqueryObjects[mockEle].toggleClass("MOCK_CLASS",true)
        )
        test("Subsequent calls on same binder - calls JQ toggleClass using previously appended class on element with false", ()->
          mockEle ={}
          RivetsExtensions.binders.classappend(mockEle,"MOCK_CLASS")
          RivetsExtensions.binders.classappend(mockEle,"MOCK_CLASS_NEXT")
          mocks.jqueryObjects[mockEle].toggleClass("MOCK_CLASS",false)
          RivetsExtensions.binders.classappend(mockEle,"MOCK_CLASS")
          mocks.jqueryObjects[mockEle].toggleClass("MOCK_CLASS_NEXT",false)
          RivetsExtensions.binders.classappend(mockEle,"MOCK_CLASS_ANOTHER")
          mocks.jqueryObjects[mockEle].toggleClass("MOCK_CLASS",false)
        )
      )
    )
    suite("formatters", ()->
      suite("rotateCss", ()->
        test("formatsStringInputAsCssRotateDegrees", ()->
          a.equal(RivetsExtensions.formatters.rotateCss("MOCK_VALUE"),"rotate(MOCK_VALUEdeg)")
        )
        test("formatsIntegerInputAsCssRotateDegrees", ()->
          a.equal(RivetsExtensions.formatters.rotateCss(123),"rotate(123deg)")

        )
        test("formatsFloatingPointInputAsCssRotateDegrees", ()->
          a.equal(RivetsExtensions.formatters.rotateCss(1.23),"rotate(1.23deg)")

        )
        test("formatsFloatingPointInputLosesTrailingZeros", ()->
          a.equal(RivetsExtensions.formatters.rotateCss(1.2300),"rotate(1.23deg)")

        )
        test("usesValueOfInComplexObject", ()->
          a.equal(RivetsExtensions.formatters.rotateCss(
            a:
              b:{}
            c:9
            valueOf:()->"VALUEOF_VAL"
          ),"rotate(VALUEOF_VALdeg)")
        )


      )
      suite("toggle", ()->
        test("toggleUndefinedValueUndefinedReturnsUndefined", ()->
          a.isUndefined(RivetsExtensions.formatters.toggle())
        )
        test("toggleFalseValueUndefinedReturnsUndefined", ()->
          a.isUndefined(RivetsExtensions.formatters.toggle(false))
        )
        test("toggleFalseValueDefinedReturnsUndefined", ()->
          a.isUndefined(RivetsExtensions.formatters.toggle(false,"MOCK_VALUE"))
        )
        test("toggleTrueValueUndefinedReturnsUndefined", ()->
          a.isUndefined(RivetsExtensions.formatters.toggle(true))
        )
        test("toggleTrueValueStringReturnsValue", ()->
          a.equal(RivetsExtensions.formatters.toggle(true,"MOCK_VALUE"),"MOCK_VALUE")
        )
        test("toggleTrueValueObjectReturnsValue", ()->
          val={}
          a.equal(RivetsExtensions.formatters.toggle(true,val),val)
        )
        test("toggleObjectValueUndefinedReturnsUndefined", ()->
          a.isUndefined(RivetsExtensions.formatters.toggle({}))
        )
        test("toggleObjectValueStringReturnsValue", ()->
          a.equal(RivetsExtensions.formatters.toggle({},"MOCK_VALUE"),"MOCK_VALUE")
        )
        test("toggleObjectValueObjectReturnsValue", ()->
          val={}
          a.equal(RivetsExtensions.formatters.toggle({},val),val)
        )
      )
      suite("sprintf",()->
        test("callsSprintWithFirstParamValSecondParamPattern",()->
          ret = RivetsExtensions.formatters.sprintf("MOCK_VALUE","MOCK_MASK")
          a.equal(ret.mask,"MOCK_MASK")
          a.equal(ret.value,"MOCK_VALUE")
        )
      )
      suite("multiplier",()->
        test("decimalInputdecimalMultiplierNoMask_ReturnsMultiplied",()->
          ret = RivetsExtensions.formatters.multiplier("3.5", "2.5")
          a.equal(ret,"8.75")
        )
        test("IntegerInputIntegerMultiplierNoMask_ReturnsMultiplied",()->
          ret = RivetsExtensions.formatters.multiplier("9","5")
          a.equal(ret, "45")
        )
        test("decimalInputdecimalMultiplierMaskSetMask_ReturnsSPrintfResultUsingMultipliedWithMask",()->
          ret = RivetsExtensions.formatters.multiplier("3.5", "2.5" ,"MOCK_MASK")
          a.equal(ret.mask,"MOCK_MASK")
          a.equal(ret.value,"8.75")
        )
        test("NonNumericInputNoMask_ReturnsUnmodifiedInput",()->
          ret = RivetsExtensions.formatters.multiplier("NOT A NUMBER", "2.5" )
          a.equal(ret,"NOT A NUMBER")
        )
        test("NonNumericMultiplierNoMask_ReturnsUnmodifiedInput",()->
          ret = RivetsExtensions.formatters.multiplier("2.5", "NOT A NUMBER")
          a.equal(ret,"2.5")
        )
        test("NonNumericInputWithMask_ReturnsSPreintfResultUsingUnmodifiedInputdWithMask",()->
          ret = RivetsExtensions.formatters.multiplier("NOT A NUMBER", "2.5" ,"MOCK_MASK")
          a.equal(ret.mask,"MOCK_MASK")
          a.equal(ret.value,"NOT A NUMBER")
        )
        test("NonNumericInputWithMask_ReturnsSPreintfResultUsingUnmodifiedInputdWithMask",()->
          ret = RivetsExtensions.formatters.multiplier("2.5","NOT A NUMBER" ,"MOCK_MASK")
          a.equal(ret.mask,"MOCK_MASK")
          a.equal(ret.value,"2.5")
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
            a.equal(RivetsExtensions.formatters.centroid(input, "MOCK_POS","MOCK_DIM"), 9)
          )
          test("Dimension set as zero - returns position supplied", ()->
            input.set(
              MOCK_POS:10
              MOCK_DIM:0
            )
            a.equal(RivetsExtensions.formatters.centroid(input, "MOCK_POS","MOCK_DIM"), 10)
          )
          test("Dimension set as negative - returns position supplied plus half negative dimension", ()->
            input.set(
              MOCK_POS:10
              MOCK_DIM:-2
            )
            a.equal(RivetsExtensions.formatters.centroid(input, "MOCK_POS","MOCK_DIM"), 11)
          )
          test("Dimension not set - throws", ()->
            input.set(
              "MOCK_POS":10
            )
            a.throw(()->RivetsExtensions.formatters.centroid(input, "MOCK_POS","MOCK_DIM"))
          )
          test("Dimension not numeric - throws", ()->
            input.set(
              "MOCK_POS":10
              "MOCK_DIM":"NOT A NUMBER"
            )
            a.throw(()->RivetsExtensions.formatters.centroid(input, "MOCK_POS","MOCK_DIM"))
          )
          test("Dimension converts to numeric - converts", ()->
            input.set(
              MOCK_POS:10
              MOCK_DIM:"-3"
            )
            a.equal(RivetsExtensions.formatters.centroid(input, "MOCK_POS","MOCK_DIM"), 11.5)
          )
          test("Position undefined - throws", ()->
            input.set(
              MOCK_DIM:2
            )
            a.throw(()->RivetsExtensions.formatters.centroid(input, "MOCK_POS","MOCK_DIM"))
          )
          test("Position not numeric - throws", ()->
            input.set(
              MOCK_POS:"NOT A NUMBER"
              MOCK_DIM:2
            )
            a.throw(()->RivetsExtensions.formatters.centroid(input, "MOCK_POS","MOCK_DIM"))
          )
          test("Position converts to numeric - converts", ()->
            input.set(
              MOCK_POS:"12.5"
              MOCK_DIM:2
            )
            a.equal(RivetsExtensions.formatters.centroid(input, "MOCK_POS","MOCK_DIM"), 11.5)
          )
          test("Position and Dimension converts to numeric - converts", ()->
            input.set(
              MOCK_POS:"12.5"
              MOCK_DIM:"2"
            )
            a.equal(RivetsExtensions.formatters.centroid(input, "MOCK_POS","MOCK_DIM"), 11.5)
          )
        )
        test("Position not set - throws", ()->
          input.set(
            MOCK_POS:10
            MOCK_DIM:2
          )
          a.throw(()->RivetsExtensions.formatters.centroid(input, undefined,"MOCK_DIM"))
        )
        test("Position attribute not on input model - throws", ()->
          input.set(
            NOT_MOCK_POS:10
            MOCK_DIM:2
          )
          a.throw(()->RivetsExtensions.formatters.centroid(input, "MOCK_POS","MOCK_DIM"))
        )
        test("Dimension not set - throws", ()->
          input.set(
            MOCK_POS:10
            MOCK_DIM:2
          )
          a.throw(()->RivetsExtensions.formatters.centroid(input, "MOCK_POS"))
        )
        test("Dimension attribute not on input model - throws", ()->
          input.set(
            MOCK_POS:10
            NOT_MOCK_DIM:2
          )
          a.throw(()->RivetsExtensions.formatters.centroid(input, "MOCK_POS","MOCK_DIM"))
        )
      )
    )
  )

)

