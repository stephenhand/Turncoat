require(["isolate", "isolateHelper"], (Isolate, Helper)->

)

define(["isolate!state/ManOWarGameState", "jsMockito", "jsHamcrest", "chai"], (ManOWarGameState, jm, h, c)->
  mocks = window.mockLibrary["state/ManOWarGameState"]
  m = h.Matchers
  a = c.assert
  v = jm.Verifiers
  suite("ManOWarGameState", ()->
    suite("someMethod", ()->
      test("someTest", ()->
        a.fail()
      )
    )
  )


)

