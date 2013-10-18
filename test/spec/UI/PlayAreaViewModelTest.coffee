updateFromWatchedCollectionsRes=null
require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("AppState","UI/PlayAreaViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      get:()->
    )
  )

  Isolate.mapAsFactory("UI/component/ObservingViewModelItem","UI/PlayAreaViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      actual
    )
  )


  Isolate.mapAsFactory("UI/FleetAsset2DViewModel","UI/PlayAreaViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      mockFleetAsset2DModel = (option)->
        mockConstructedFA2DM = JsMockito.mock(actual)
        JsMockito.when(mockConstructedFA2DM.get)(JsHamcrest.Matchers.anything()).then(
          (att)->
            switch(att)
              when "modelId"
                mockConstructedFA2DM.modelId
        )
        mockConstructedFA2DM.modelId = option?.model.id
        mockConstructedFA2DM.cid=option?.model.id
        mockConstructedFA2DM
      mockFleetAsset2DModel
    )
  )
  Isolate.mapAsFactory("UI/component/ObservingViewModelCollection","UI/PlayAreaViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      mockObservingViewModelCollection = (data)->
        mockConstructedBVMC = new Backbone.Collection(data)
        mockConstructedBVMC.watch = JsMockito.mockFunction()
        mockConstructedBVMC.unwatch = JsMockito.mockFunction()
        JsMockito.when(mockConstructedBVMC.watch)(JsHamcrest.Matchers.anything()).then((collections)->
          mockConstructedBVMC.watchedCollections = collections
        )
        mockConstructedBVMC.updateFromWatchedCollections = JsMockito.mockFunction()
        JsMockito.when(mockConstructedBVMC.updateFromWatchedCollections)(JsHamcrest.Matchers.anything(),JsHamcrest.Matchers.anything()).then((c,a, s)->
          updateFromWatchedCollectionsRes=
            comparer:c
            adder:a
            selector:s
        )
        mockConstructedBVMC
      mockObservingViewModelCollection
    )
  )
)

define(["isolate!UI/PlayAreaViewModel", "lib/turncoat/GameStateModel"], (PlayAreaViewModel, GameStateModel)->
  suite("PlayAreaViewModel", ()->
    gsm = null
    mocks = mockLibrary["UI/PlayAreaViewModel"]
    setup(()->
      mocks["UI/component/ObservingViewModelItem"].prototype.watch = JsMockito.mockFunction()
      mocks["UI/component/ObservingViewModelItem"].prototype.unwatch = JsMockito.mockFunction()
    )
    suite("initialise", ()->
      test("No options specified - Watches global AppState game attribute", ()->
        pavm = new PlayAreaViewModel()
        JsMockito.verify(pavm.watch)(
          JsHamcrest.Matchers.both(
            JsHamcrest.Matchers.hasMember("model",mocks["AppState"]), JsHamcrest.Matchers.hasMember("attributes",JsHamcrest.Matchers.equivalentArray(["game"]))
          )
        )
      )
      test("No appState option specified - Watches global AppState game attribute", ()->
        pavm = new PlayAreaViewModel({})
        JsMockito.verify(pavm.watch)(
          JsHamcrest.Matchers.both(
            JsHamcrest.Matchers.hasMember("model",mocks["AppState"]), JsHamcrest.Matchers.hasMember("attributes",JsHamcrest.Matchers.equivalentArray(["game"]))
          )
        )
      )
      test("appState specified in options - Watches options appsState game attribute", ()->
        myState =
          get:(key)->
            if key is "game" then JsMockito.mock(GameStateModel)
        pavm = new PlayAreaViewModel(appState:myState)
        JsMockito.verify(pavm.watch)(
          JsHamcrest.Matchers.both(
            JsHamcrest.Matchers.hasMember("model", myState), JsHamcrest.Matchers.hasMember("attributes",JsHamcrest.Matchers.equivalentArray(["game"]))
          )
        )
      )
    )
    suite("onModelUpdated", ()->
      setup(()->
        gsm = JsMockito.mock(GameStateModel)
        mocks["AppState"].get = JsMockito.mockFunction()
        JsMockito.when(mocks["AppState"].get)("game").then((g)->gsm)
        JsMockito.when(gsm.get)("id").then((key)->
          "GSM_ID"
        )
        JsMockito.when(gsm.searchChildren)(JsHamcrest.Matchers.anything()).then((func)->
          if gsm.watchCollection then [gsm.watchCollection] else []
        )
      )

      test("AppState has game loaded sets Ships to watch game state", ()->
        pavm = new PlayAreaViewModel()
        pavm.watch = JsMockito.mockFunction()
        pavm.onModelUpdated(gsm)
        JsMockito.verify(pavm.get("ships").watch)()
      )

      test("AppState Game Not Set unwatches ships", ()->
        JsMockito.when(gsm.get)("id").then((key)->)
        pavm = new PlayAreaViewModel()
        pavm.get("ships").unwatch = JsMockito.mockFunction()
        pavm.onModelUpdated(gsm)
        JsMockito.verify(pavm.get("ships").unwatch)()
      )
    )
    suite("Update watched ships collections", ()->
      gsmWithOneCollection = JsMockito.mock(GameStateModel)
      setup(()->
        gsmWithOneCollection.watchCollection = new Backbone.Collection([
          new mocks["state/FleetAsset"]
        ])
        gsmWithOneCollection.watchCollection.at(0).id="MOCK_FLEETASSET0_UUID"
        JsMockito.when(gsmWithOneCollection.searchChildren)(JsHamcrest.Matchers.anything()).then((func)->
          if gsmWithOneCollection.watchCollection then [gsmWithOneCollection.watchCollection] else []
        )
        JsMockito.when(mocks["AppState"].get)("game").then((g)->
          gsmWithOneCollection
        )

      )
      teardown(()->
        updateFromWatchedCollectionsRes=null
      )

      test("callsUpdateFromWatchedCollectionsWithFunctions", ()->
        pavm = new PlayAreaViewModel()
        JsMockito.verify(pavm.get("ships").updateFromWatchedCollections)(JsHamcrest.Matchers.func(),JsHamcrest.Matchers.func())
      )
      test("callsUpdateFromWatchedCollectionsWithComparerThatIdentifiesMatchesOnModelIdToId", ()->
        pavm = new PlayAreaViewModel()

        chai.assert(
          updateFromWatchedCollectionsRes.comparer(
            get:(key)->
              if key=="modelId" then 1 else 0
          ,
            id:1
          )
        )
      )
      test("callsUpdateFromWatchedCollectionsWithComparerThatFailsOnModelIdNotId", ()->
        pavm = new PlayAreaViewModel()

        chai.assert.isFalse(
          updateFromWatchedCollectionsRes.comparer(
            get:(key)->
              if key=="modelId" then 1 else 0
          ,
            id:3
          )
        )
      )
      test("callsUpdateFromWatchedCollectionsWithComparerThatFailsOnModelIdNotExactlyId", ()->
        pavm = new PlayAreaViewModel()

        chai.assert.isFalse(
          updateFromWatchedCollectionsRes.comparer(
            get:(key)->
              if key=="modelId" then 1 else 0
          ,
            id:'1'

          )
        )
      )
      test("callsUpdateFromWatchedCollectionsWithComparerThatFailsOnBothUndefined", ()->
        pavm = new PlayAreaViewModel()

        chai.assert(
          updateFromWatchedCollectionsRes.comparer(
            get:(key)->undefined
          ,{}
          )
        )
      )
    )
  )


)

