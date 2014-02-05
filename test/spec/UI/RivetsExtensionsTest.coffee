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

define(['isolate!UI/RivetsExtensions'], (RivetsExtensions)->
  mocks=window.mockLibrary['UI/RivetsExtensions']
  suite("RivetsExtensions", ()->
    suite("binders", ()->
      suite("style_top", ()->
        test("setsStyleTopOnElement", ()->
          mockEle =
            style:
              top:"UNSET"
          RivetsExtensions.binders.style_top(mockEle, "MOCK_VALUE")
          chai.assert.equal(mockEle.style.top, "MOCK_VALUE")
        )
        test("throwsForInvalidElement", ()->
          mockEle ={}
          chai.assert.throws(()->
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
          chai.assert.equal(mockEle.style.left, "MOCK_VALUE")
        )
        test("throwsForInvalidElement", ()->
          mockEle ={}
          chai.assert.throws(()->
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
          chai.assert.equal(mockEle.style.transform, "MOCK_VALUE")
        )
        test("setsStyleWebKitTransformOnElement", ()->
          mockEle =
            style:
              left:"UNSET"
          RivetsExtensions.binders.style_transform(mockEle, "MOCK_VALUE")
          chai.assert.equal(mockEle.style.webkitTransform, "MOCK_VALUE")
        )
        test("setsStyleMSTransformOnElement", ()->
          mockEle =
            style:
              left:"UNSET"
          RivetsExtensions.binders.style_transform(mockEle, "MOCK_VALUE")
          chai.assert.equal(mockEle.style.msTransform, "MOCK_VALUE")
        )
        test("throwsForInvalidElement", ()->
          mockEle ={}
          chai.assert.throws(()->
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
          chai.assert.equal(RivetsExtensions.formatters.rotateCss("MOCK_VALUE"),"rotate(MOCK_VALUEdeg)")
        )
        test("formatsIntegerInputAsCssRotateDegrees", ()->
          chai.assert.equal(RivetsExtensions.formatters.rotateCss(123),"rotate(123deg)")

        )
        test("formatsFloatingPointInputAsCssRotateDegrees", ()->
          chai.assert.equal(RivetsExtensions.formatters.rotateCss(1.23),"rotate(1.23deg)")

        )
        test("formatsFloatingPointInputLosesTrailingZeros", ()->
          chai.assert.equal(RivetsExtensions.formatters.rotateCss(1.2300),"rotate(1.23deg)")

        )
        test("usesValueOfInComplexObject", ()->
          chai.assert.equal(RivetsExtensions.formatters.rotateCss(
            a:
              b:{}
            c:9
            valueOf:()->"VALUEOF_VAL"
          ),"rotate(VALUEOF_VALdeg)")
        )


      )
      suite("toggle", ()->
        test("toggleUndefinedValueUndefinedReturnsUndefined", ()->
          chai.assert.isUndefined(RivetsExtensions.formatters.toggle())
        )
        test("toggleFalseValueUndefinedReturnsUndefined", ()->
          chai.assert.isUndefined(RivetsExtensions.formatters.toggle(false))
        )
        test("toggleFalseValueDefinedReturnsUndefined", ()->
          chai.assert.isUndefined(RivetsExtensions.formatters.toggle(false,"MOCK_VALUE"))
        )
        test("toggleTrueValueUndefinedReturnsUndefined", ()->
          chai.assert.isUndefined(RivetsExtensions.formatters.toggle(true))
        )
        test("toggleTrueValueStringReturnsValue", ()->
          chai.assert.equal(RivetsExtensions.formatters.toggle(true,"MOCK_VALUE"),"MOCK_VALUE")
        )
        test("toggleTrueValueObjectReturnsValue", ()->
          val={}
          chai.assert.equal(RivetsExtensions.formatters.toggle(true,val),val)
        )
        test("toggleObjectValueUndefinedReturnsUndefined", ()->
          chai.assert.isUndefined(RivetsExtensions.formatters.toggle({}))
        )
        test("toggleObjectValueStringReturnsValue", ()->
          chai.assert.equal(RivetsExtensions.formatters.toggle({},"MOCK_VALUE"),"MOCK_VALUE")
        )
        test("toggleObjectValueObjectReturnsValue", ()->
          val={}
          chai.assert.equal(RivetsExtensions.formatters.toggle({},val),val)
        )
      )
      suite("sprintf",()->
        test("callsSprintWithFirstParamValSecondParamPattern",()->
          ret = RivetsExtensions.formatters.sprintf("MOCK_VALUE","MOCK_MASK")
          chai.assert.equal(ret.mask,"MOCK_MASK")
          chai.assert.equal(ret.value,"MOCK_VALUE")
        )
      )
      suite("multiplier",()->
        test("decimalInputdecimalMultiplierNoMask_ReturnsMultiplied",()->
          ret = RivetsExtensions.formatters.multiplier("3.5", "2.5")
          chai.assert.equal(ret,"8.75")
        )
        test("IntegerInputIntegerMultiplierNoMask_ReturnsMultiplied",()->
          ret = RivetsExtensions.formatters.multiplier("9","5")
          chai.assert.equal(ret, "45")
        )
        test("decimalInputdecimalMultiplierMaskSetMask_ReturnsSPrintfResultUsingMultipliedWithMask",()->
          ret = RivetsExtensions.formatters.multiplier("3.5", "2.5" ,"MOCK_MASK")
          chai.assert.equal(ret.mask,"MOCK_MASK")
          chai.assert.equal(ret.value,"8.75")
        )
        test("NonNumericInputNoMask_ReturnsUnmodifiedInput",()->
          ret = RivetsExtensions.formatters.multiplier("NOT A NUMBER", "2.5" )
          chai.assert.equal(ret,"NOT A NUMBER")
        )
        test("NonNumericMultiplierNoMask_ReturnsUnmodifiedInput",()->
          ret = RivetsExtensions.formatters.multiplier("2.5", "NOT A NUMBER")
          chai.assert.equal(ret,"2.5")
        )
        test("NonNumericInputWithMask_ReturnsSPreintfResultUsingUnmodifiedInputdWithMask",()->
          ret = RivetsExtensions.formatters.multiplier("NOT A NUMBER", "2.5" ,"MOCK_MASK")
          chai.assert.equal(ret.mask,"MOCK_MASK")
          chai.assert.equal(ret.value,"NOT A NUMBER")
        )
        test("NonNumericInputWithMask_ReturnsSPreintfResultUsingUnmodifiedInputdWithMask",()->
          ret = RivetsExtensions.formatters.multiplier("2.5","NOT A NUMBER" ,"MOCK_MASK")
          chai.assert.equal(ret.mask,"MOCK_MASK")
          chai.assert.equal(ret.value,"2.5")
        )
      )
    )
  )

)

