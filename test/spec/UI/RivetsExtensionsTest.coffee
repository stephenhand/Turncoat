require(["isolate","isolateHelper"], (Isolate, Helper)->

  Isolate.mapAsFactory("rivets","UI/RivetsExtensions", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      stubRivets =
        binders:{}
        formatters:{}
      stubRivets
    )
  )
)


define(['isolate!UI/RivetsExtensions'], (RivetsExtensions)->
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
    )
  )

)

