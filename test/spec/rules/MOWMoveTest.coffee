require(["isolate", "isolateHelper"], (Isolate, Helper)->

)

define(["isolate!rules/MOWMove", "jsMockito", "jsHamcrest", "chai"], (MOWMove, jm, h, c)->
  mocks = window.mockLibrary["rules/MOWMove"]
  m = h.Matchers
  a = c.assert
  v = jm.Verifiers
  suite("MOWMove", ()->
    suite("getEndControllingPlayer", ()->
      test("someTest", ()->
        a.fail()
      )
    )
  )


)

