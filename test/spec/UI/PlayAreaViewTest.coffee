updateFromWatchedCollectionsRes=null

require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("AppState","UI/PlayAreaView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      loadGame:(id)->
    )
  )
  Isolate.mapAsFactory("UI/PlayAreaViewModel","UI/PlayAreaView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      (model, opts)->
        constructedWith:model
        constructedWithOpts:opts
        setGame:()->
    )
  )
  Isolate.mapAsFactory("UI/board/AssetSelectionOverlayView","UI/PlayAreaView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      class ret
      ret
    )
  )
)

define(["isolate!UI/PlayAreaView", "jsMockito", "jsHamcrest", "chai"], (PlayAreaView, jm, h, c)->
  suite("PlayAreaView", ()->
    m = h.Matchers
    a = c.assert
    v = jm.Verifiers
    mocks = mockLibrary["UI/PlayAreaView"]
    suite("createModel", ()->
      test("Sets Model as new PlayAreaViewModel without model parameter", ()->

        pav = new PlayAreaView(gameState:{})

        pav.createModel()
        a.isDefined(pav.model)
        a.isFalse(pav.model.constructedWith?)
      )
      test("Sets Model as new PlayAreaViewModel without option parameter specifying assetSelectionView as AssetSelectionViewObject", ()->

        pav = new PlayAreaView(gameState:{})

        pav.createModel()
        a.isDefined(pav.model)
        a.instanceOf(pav.model.constructedWithOpts.assetSelectionView, mocks["UI/board/AssetSelectionOverlayView"])
      )
    )
    suite("routeChanged", ()->
      pav = null
      setup(()->
        mocks["AppState"].loadGame = jm.mockFunction()
        jm.when(mocks["AppState"].loadGame)(m.anything()).then((id)->
          loadedGameId:id
        )
        pav = new PlayAreaView(gameState:{})
        pav.createModel()
        pav.model.setGame = jm.mockFunction()
      )
      test("Route has 2 parts - uses 2nd part as identifier to load game", ()->
        pav.routeChanged(parts:[
          "PART 1"
        ,
          "PART 2"
        ])
        jm.verify(mocks["AppState"].loadGame)("PART 2")
      )
      test("Route has 2 parts - sets game with loaded game", ()->
        pav.routeChanged(parts:[
          "PART 1"
        ,
          "PART 2"
        ])
        jm.verify(pav.model.setGame)(m.hasMember("loadedGameId","PART 2"))
      )
      test("Route has more than 2 parts - sets game with loaded game", ()->
        pav.routeChanged(parts:[
          "PART 1"
        ,
          "PART 2"
        ,
          "PART 3"
        ,
          "PART 4"
        ])
        jm.verify(pav.model.setGame)(m.hasMember("loadedGameId","PART 2"))
      )
      test("Route has less than 2 parts - unsets game", ()->
        pav.routeChanged(parts:["PART 1"])
        jm.verify(pav.model.setGame)()
      )
      test("Route has parts not defined - unsets game", ()->
        pav.routeChanged(parts:["PART 1"])
        jm.verify(pav.model.setGame)()
      )
      test("Route not set - throws", ()->
        a.throws(()=>pav.routeChanged())
      )
    )
  )


)

