
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

define(["isolate!UI/widgets/GameBoardViewModel", "matchers", "operators", "assertThat","jsMockito", "verifiers", "backbone"], (GameBoardViewModel , m, o, a, jm, v, Backbone)->
  mocks = window.mockLibrary["UI/widgets/GameBoardViewModel"]
  suite("GameBoardViewModel", ()->
    suite("initialize", ()->
      test("Creates 'ships' attribute as ObservingViewModelCollection", ()->
        gbvm = new GameBoardViewModel()
        a(gbvm.get("ships"), m.instanceOf(mocks["UI/component/ObservingViewModelCollection"]))
      )
      test("Creates 'overlays' attribute as Backbone Collection", ()->
        gbvm = new GameBoardViewModel()
        a(gbvm.get("overlays"), m.instanceOf(Backbone.Collection))
      )
      test("Creates 'underlays' attribute as Backbone Collection", ()->
        gbvm = new GameBoardViewModel()
        a(gbvm.get("underlays"), m.instanceOf(Backbone.Collection))
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
        test("Calls setGame on overlayModel attribute of all overlays with same game.", ()->
          setter = Backbone.Model.extend(
            initialize:()->

              @setGame=jm.mockFunction()
          )
          gbvm.get("overlays").push(overlayModel:new setter())
          gbvm.get("overlays").push(overlayModel:new setter())
          gbvm.get("overlays").push(overlayModel:new setter())
          gbvm.setGame(gsm)
          jm.verify(gbvm.get("overlays").at(0).get("overlayModel").setGame)(gsm)
          jm.verify(gbvm.get("overlays").at(1).get("overlayModel").setGame)(gsm)
          jm.verify(gbvm.get("overlays").at(2).get("overlayModel").setGame)(gsm)
        )
        test("Calls setGame on all underlays with same game.", ()->
          setter = Backbone.Model.extend(
            initialize:()->
              @setGame=jm.mockFunction()
          )
          gbvm.get("underlays").push(overlayModel:new setter())
          gbvm.get("underlays").push(overlayModel:new setter())
          gbvm.get("underlays").push(overlayModel:new setter())
          gbvm.setGame(gsm)
          jm.verify(gbvm.get("underlays").at(0).get("overlayModel").setGame)(gsm)
          jm.verify(gbvm.get("underlays").at(1).get("overlayModel").setGame)(gsm)
          jm.verify(gbvm.get("underlays").at(2).get("overlayModel").setGame)(gsm)
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
          gbvm.get("overlays").push(overlayModel:new setter())
          gbvm.get("overlays").push(overlayModel:new setter())
          gbvm.get("overlays").push(overlayModel:new setter())
          gbvm.setGame()
          jm.verify(gbvm.get("overlays").at(0).get("overlayModel").setGame)(m.nil())
          jm.verify(gbvm.get("overlays").at(1).get("overlayModel").setGame)(m.nil())
          jm.verify(gbvm.get("overlays").at(2).get("overlayModel").setGame)(m.nil())
        )
        test("Calls setGame on all overlays with nothing.", ()->
          setter = Backbone.Model.extend(
            initialize:()->
              @setGame=jm.mockFunction()
          )
          gbvm.get("underlays").push(overlayModel:new setter())
          gbvm.get("underlays").push(overlayModel:new setter())
          gbvm.get("underlays").push(overlayModel:new setter())
          gbvm.setGame()
          jm.verify(gbvm.get("underlays").at(0).get("overlayModel").setGame)(m.nil())
          jm.verify(gbvm.get("underlays").at(1).get("overlayModel").setGame)(m.nil())
          jm.verify(gbvm.get("underlays").at(2).get("overlayModel").setGame)(m.nil())
        )
      )
      test("Overlays not set - throws", ()->
        gbvm.unset("overlays")
        a(
          ()->gbvm.setGame(gsm)
        , m.raisesAnything())
      )
      test("Overlays contains objects with no overlayModel - does nothing", ()->
        gbvm.get("overlays").push({})
        a(
          ()->gbvm.setGame(gsm)
        , m.not(m.raisesAnything()))
      )
      test("Overlays contains objects with overlayModels with no setGame method - throws", ()->
        gbvm.get("overlays").push({overlayModel:{}})
        a(
          ()->gbvm.setGame(gsm)
        , m.raisesAnything())
      )
      test("Underlays not set - throws", ()->
        gbvm.unset("underlays")
        a(
          ()->gbvm.setGame(gsm)
        , m.raisesAnything())
      )
      test("Underlays contains objects with no overlayModel - does nothing", ()->
        gbvm.get("underlays").push({})
        a(
          ()->gbvm.setGame(gsm)
        , m.not(m.raisesAnything()))
      )
      test("Underlays contains objects with overlayModels with no setGame method - throws", ()->
        gbvm.get("underlays").push({overlayModel:{}})
        a(
          ()->gbvm.setGame(gsm)
        , m.raisesAnything())
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

          a(comparer(
              get:(key)->
                if key=="modelId" then 1 else 0
            ,
              id:1
            ),true
          )
        )
        test("Model Id not Id - fails", ()->
          a(comparer(
              get:(key)->
                if key=="modelId" then 1 else 0
            ,
              id:3
            ),false
          )
        )
        test("Fails on model Id not exactly Id - fails", ()->
          a(comparer(
              get:(key)->
                if key=="modelId" then 1 else 0
            ,
              id:'1'

            ),false
          )
        )
        test("Both ids undefined - fails", ()->
          a(comparer(
              get:(key)->undefined
            ,{}
            ),true
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
          a(adder({}),m.instanceOf(mocks["UI/FleetAsset2DViewModel"]))
        )
        test("Option specified without model type - Creates new FleetAsset2DModel", ()->
          gbvm = new GameBoardViewModel(null,{})
          jm.when(gbvm.get("ships").updateFromWatchedCollections)(m.func(),m.func(),m.func()).then((c,a,f)->
            adder = a
          )
          gbvm.setGame(gsmWithOneCollection)
          a(adder({}),m.instanceOf(mocks["UI/FleetAsset2DViewModel"]))

        )

        test("Option specified with model type - Creates new object of specified type", ()->
          class MockModelType
          gbvm = new GameBoardViewModel(null, modelType:MockModelType)
          jm.when(gbvm.get("ships").updateFromWatchedCollections)(m.func(),m.func(),m.func()).then((c,a,f)->
            adder = a
          )
          gbvm.setGame(gsmWithOneCollection)
          a(adder({}),m.instanceOf(MockModelType))

        )
        test("Creates new model with model option set to input", ()->
          mod = {}
          a(adder(mod).inputModel,mod)
        )
        test("Null input - creates new model with model option set to null", ()->
          a(adder().inputModel, m.nil())
        )
        test("Game option set to game set", ()->
          a(adder({}).inputGame, gsmWithOneCollection)
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
          a(filter(new mocks["state/FleetAsset"]()), true)
        )
        test("Input is not FleetAsset - false", ()->
          a(filter({}), false)
        )
        test("Input is not defined - false", ()->
          a(filter(), false)
        )
      )
    )
  )


)

