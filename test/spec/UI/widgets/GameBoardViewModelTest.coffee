
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
        constructor:(wm, opt)->
          @inputModel = opt.model
          @inputGame = opt.game
      ret
    )
  )
)

define(["isolate!UI/widgets/GameBoardViewModel", "jsMockito", "jsHamcrest", "chai", "backbone"], (GameBoardViewModel, jm, h, c, Backbone)->
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
      test("Creates 'overlays' attribute as Backbone Collection", ()->
        gbvm = new GameBoardViewModel()
        a.instanceOf(gbvm.get("overlays"), Backbone.Collection)
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
      suite("Game specified", ()->
        test("unwatches", ()->
          gbvm.setGame(gsm)
          jm.verify(gbvm.get("ships").unwatch)()
        )
        test("sets ships to watch new game state after unwatching", ()->
          gsm.watchCollection = []
          gbvm.get("ships").watch = null
          jm.when(gbvm.get("ships").unwatch)().then(()->
            gbvm.get("ships").watch = jm.mockFunction()
          )
          gbvm.setGame(gsm)
          jm.verify(gbvm.get("ships").watch)(m.equivalentArray([gsm.watchCollection]))

        )
        test("Calls setGame on all overlays with same game.", ()->
          setter = Backbone.Model.extend(
            initialize:()->
              @setGame=jm.mockFunction()
          )
          gbvm.get("overlays").push(new setter())
          gbvm.get("overlays").push(new setter())
          gbvm.get("overlays").push(new setter())
          gbvm.setGame(gsm)
          jm.verify(gbvm.get("overlays").at(0).setGame)(gsm)
          jm.verify(gbvm.get("overlays").at(1).setGame)(gsm)
          jm.verify(gbvm.get("overlays").at(2).setGame)(gsm)
        )
      )
      suite("Game not specified", ()->
        test("Unwatches ships without rewatching anything", ()->
          gbvm.setGame()
          jm.verify(gbvm.get("ships").unwatch)()
          jm.verify(gbvm.get("ships").watch, v.never())(m.anything())
        )
        test("Calls setGame on all overlays with nothing.", ()->
          setter = Backbone.Model.extend(
            initialize:()->
              @setGame=jm.mockFunction()
          )
          gbvm.get("overlays").push(new setter())
          gbvm.get("overlays").push(new setter())
          gbvm.get("overlays").push(new setter())
          gbvm.setGame()
          jm.verify(gbvm.get("overlays").at(0).setGame)(m.nil())
          jm.verify(gbvm.get("overlays").at(1).setGame)(m.nil())
          jm.verify(gbvm.get("overlays").at(2).setGame)(m.nil())
        )
      )
      test("Overlays not set - throws", ()->
        gbvm.unset("overlays")
        a.throw(()->gbvm.setGame(gsm))
      )
      test("Overlays contains objects with no setGame method - throws", ()->
        gbvm.get("overlays").push({})
        a.throw(()->gbvm.setGame(gsm))
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
          gbvm = new GameBoardViewModel(null,{})
          jm.when(gbvm.get("ships").updateFromWatchedCollections)(m.func(),m.func(),m.func()).then((c,a,f)->
            adder = a
          )
          gbvm.setGame(gsmWithOneCollection)
          a.instanceOf(adder({}),mocks["UI/FleetAsset2DViewModel"])

        )

        test("Option specified with model type - Creates new object of specified type", ()->
          class MockModelType
          gbvm = new GameBoardViewModel(null, modelType:MockModelType)
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
        test("Game option set to game set", ()->
          a.equal(adder({}).inputGame, gsmWithOneCollection)
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

