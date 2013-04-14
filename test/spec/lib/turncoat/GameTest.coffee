define(['isolate!lib/turncoat/Game'], (Game)->
  suite("GameTest", ()->
    suite("loadState", ()->
      test("stringCallsFromStringOnGameStateModel", ()->
        chai.assert.true()
      )
    )
  )

)

