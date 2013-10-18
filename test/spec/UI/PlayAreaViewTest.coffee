updateFromWatchedCollectionsRes=null

require(["isolate","isolateHelper"], (Isolate, Helper)->

  Isolate.mapAsFactory("UI/PlayAreaViewModel","UI/PlayAreaView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      (model)->
        constructedWith:model
    )
  )
)


define(["isolate!UI/PlayAreaView"], (PlayAreaView  )->
  suite("PlayAreaView", ()->
    mocks = mockLibrary["UI/PlayAreaView"]
    suite("createModel", ()->
      test("Sets Model as new PlayAreaViewModel without model parameter", ()->

        pav = new PlayAreaView(gameState:{})

        pav.createModel()
        chai.assert.isDefined(pav.model)
        chai.assert.isUndefined(pav.model.constructedWith)
      )
    )
  )


)

