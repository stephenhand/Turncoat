
require(["isolate","isolateHelper"], (Isolate, Helper)->

  Isolate.mapAsFactory("state/FleetAsset","UI/widgets/GameBoardViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      class ret
      ret
    )
  )
  Isolate.mapAsFactory("UI/component/ObservingViewModelCollection","UI/widgets/GameBoardViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      class ret
        updateFromWatchedCollections:JsMockito.mockFunction()
        watch:JsMockito.mockFunction()
        unwatch:JsMockito.mockFunction()
      ret
    )
  )
  Isolate.mapAsFactory("UI/FleetAsset2DViewModel","UI/widgets/GameBoardViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      class ret
        constructor:(wm)->
          @inputModel = wm.model
      ret
    )
  )
)

define(["isolate!UI/widgets/GameBoardViewModel", "jsMockito", "jsHamcrest", "chai"], (GameBoardViewModel, jm, h, c)->
  mocks = window.mockLibrary["UI/widgets/GameBoardViewModel"]
  m = h.Matchers
  a = c.assert
  v = jm.Verifiers
  suite("GameBoardViewModel", ()->
    suite("initialize", ()->
      test("Creates 'ships' attribute as ObservingViewModelCollection", ()->
        gbvm = new GameBoardViewModel()
        a.instanceOf(gbvm.get("ships"), mocks["UI/component/ObservingViewModelCollection"])
      )
    )
    suite("setGame", ()->
      gbvm = null
      gsm = null
      setup(()->
        gsm =
          get:jm.mockFunction()
          searchChildren:jm.mockFunction()
        jm.when(gsm.get)("id").then((key)->
          "GSM_ID"
        )
        jm.when(gsm.searchChildren)(m.anything()).then((func)->
          if gsm.watchCollection then [gsm.watchCollection] else []
        )
        gbvm = new GameBoardViewModel()
        gbvm.get("ships").watch = jm.mockFunction()
        gbvm.get("ships").unwatch = jm.mockFunction()
      )

      test("Game specified - unwatches", ()->
        gbvm.setGame(gsm)
        jm.verify(gbvm.get("ships").unwatch)()
      )
      test("Game specified - sets ships to watch new game state after unwatching", ()->
        gsm.watchCollection = []
        gbvm.get("ships").watch = null
        jm.when(gbvm.get("ships").unwatch)().then(()->
          gbvm.get("ships").watch = jm.mockFunction()
        )
        gbvm.setGame(gsm)
        jm.verify(gbvm.get("ships").watch)(m.equivalentArray([gsm.watchCollection]))
      )


      test("Game not set - unwatches ships without rewatching anything", ()->
        gbvm.setGame()
        jm.verify(gbvm.get("ships").unwatch)()
        jm.verify(gbvm.get("ships").watch, v.never())(m.anything())
      )
    )
    suite("Ships onSourceUpdated", ()->
      gsmWithOneCollection = null
      gbvm = null
      setup(()->
        gsmWithOneCollection =
          get:jm.mockFunction()
          searchChildren:jm.mockFunction()
        gsmWithOneCollection.watchCollection = new Backbone.Collection([
          {}
        ])
        gsmWithOneCollection.watchCollection.at(0).id="MOCK_FLEETASSET0_UUID"
        jm.when(gsmWithOneCollection.searchChildren)(m.anything()).then((func)->
          if gsmWithOneCollection.watchCollection then [gsmWithOneCollection.watchCollection] else []
        )

        gbvm = new GameBoardViewModel()
        gbvm.get("ships").updateFromWatchedCollections = jm.mockFunction()
      )

      test("Calls ships updateFromWatchedCollections", ()->
        gbvm.setGame(gsmWithOneCollection)
        jm.verify(gbvm.get("ships").updateFromWatchedCollections)(m.func(),m.func())
      )
      suite("updateFromWatchedCollections comparer", ()->
        comparer = null
        setup(()->
          jm.when(gbvm.get("ships").updateFromWatchedCollections)(m.func(),m.func(),m.func()).then((c,a,f)->
            comparer = c
          )
          gbvm.setGame(gsmWithOneCollection)
        )
        test("Model Id exactly matches Id - matches", ()->

          a.isTrue(comparer(
              get:(key)->
                if key=="modelId" then 1 else 0
            ,
              id:1
            )
          )
        )
        test("Model Id not Id - fails", ()->
          a.isFalse(comparer(
              get:(key)->
                if key=="modelId" then 1 else 0
            ,
              id:3
            )
          )
        )
        test("Fails on model Id not exactly Id - fails", ()->
          a.isFalse(comparer(
              get:(key)->
                if key=="modelId" then 1 else 0
            ,
              id:'1'

            )
          )
        )
        test("Both ids undefined - fails", ()->
          chai.assert(comparer(
              get:(key)->undefined
            ,{}
            )
          )
        )
      )
      suite("updateFromWatchedCollections adder", ()->
        adder = null
        setup(()->
          jm.when(gbvm.get("ships").updateFromWatchedCollections)(m.func(),m.func(),m.func()).then((c,a,f)->
            adder = a
          )
          gbvm.setGame(gsmWithOneCollection)
        )
        test("No options specified on construction - Creates new FleetAsset2DModel", ()->
          a.instanceOf(adder({}),mocks["UI/FleetAsset2DViewModel"])
        )
        test("Option specified without model type - Creates new FleetAsset2DModel", ()->
          gbvm = new GameBoardViewModel({})
          jm.when(gbvm.get("ships").updateFromWatchedCollections)(m.func(),m.func(),m.func()).then((c,a,f)->
            adder = a
          )
          gbvm.setGame(gsmWithOneCollection)
          a.instanceOf(adder({}),mocks["UI/FleetAsset2DViewModel"])

        )

        test("Option specified without model type - Creates new FleetAsset2DModel", ()->
          class MockModelType
          gbvm = new GameBoardViewModel(modelType:MockModelType)
          jm.when(gbvm.get("ships").updateFromWatchedCollections)(m.func(),m.func(),m.func()).then((c,a,f)->
            adder = a
          )
          gbvm.setGame(gsmWithOneCollection)
          a.instanceOf(adder({}),MockModelType)

        )
        test("Creates new model with model option set to input", ()->
          mod = {}
          a.equal(adder(mod).inputModel,mod)
        )
        test("Null input - creates new model with model option set to null", ()->
          a.isUndefined(adder().inputModel)
        )
      )
      suite("updateFromWatchedCollections filter", ()->
        filter = null
        setup(()->
          jm.when(gbvm.get("ships").updateFromWatchedCollections)(m.func(),m.func(),m.func()).then((c,a,f)->
            filter = f
          )
          gbvm.setGame(gsmWithOneCollection)
        )
        test("Input is FleetAsset - true", ()->
          a.isTrue(filter(new mocks["state/FleetAsset"]()))
        )
        test("Input is not FleetAsset - false", ()->
          a.isFalse(filter({}))
        )
        test("Input is not defined - false", ()->
          a.isFalse(filter())
        )
      )
    )
  )


)

