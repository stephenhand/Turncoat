require(["isolate","isolateHelper"], (Isolate, Helper)->

  Isolate.mapAsFactory("lib/turncoat/GameStateModel","lib/turncoat/Game", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      mockGameStateModel = ()->
        mockConstructedGameStateModel
        mockGameStateModel.fromString = JsMockito.mockFunction()
      mockGameStateModel
    )
  )
)

define(['isolate!lib/turncoat/Game'], (Game)->
  suite("GameTest", ()->
    suite("loadState", ()->
      test("stringCallsFromStringOnGameStateModel", ()->
        chai.assert.true()
      )
    )
  )

)

