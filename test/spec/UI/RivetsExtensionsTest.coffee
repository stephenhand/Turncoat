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
  )

)

