updateFromWatchedCollectionsRes=null

require(["isolate","isolateHelper"], (Isolate, Helper)->

  Isolate.mapAsFactory("UI/FleetAsset2DViewModel","UI/PlayAreaView", (actual, modulePath, requestingModulePath)->
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
  Isolate.mapAsFactory("UI/component/ObservingViewModelCollection","UI/PlayAreaView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      mockObservingViewModelCollection = (data)->
        mockConstructedBVMC = new Backbone.Collection(data)
        mockConstructedBVMC.watch = JsMockito.mockFunction()
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


define(['isolate!UI/PlayAreaView', 'lib/turncoat/GameStateModel'], (PlayAreaView, GameStateModel )->
  suite("PlayAreaView", ()->
    mocks = mockLibrary["UI/PlayAreaView"]
    suite("createModel", ()->
      test("setsModelWithShips", ()->
        gsm = JsMockito.mock(GameStateModel)
        JsMockito.when(gsm.searchChildren)(JsHamcrest.Matchers.anything()).then((func)->
          if gsm.watchCollection then [gsm.watchCollection] else []
        )
        pav = new PlayAreaView(gameState:gsm)

        pav.createModel()
        chai.assert.isDefined(pav.model)
        chai.assert.property(pav.model, "ships")
      )

      test("gameStateNotSet_Throws", ()->
        pav = new PlayAreaView()

        chai.assert.throw(()->
          pav.createModel()
        )
      )
    )
    suite("updateModel", ()->
      gsmWithOneCollection = JsMockito.mock(GameStateModel)
      gsmWithOneCollection.watchCollection = new Backbone.Collection([
        new mocks["state/FleetAsset"]
      ])
      gsmWithOneCollection.watchCollection.at(0).id="MOCK_FLEETASSET0_UUID"
      JsMockito.when(gsmWithOneCollection.searchChildren)(JsHamcrest.Matchers.anything()).then((func)->
        if gsmWithOneCollection.watchCollection then [gsmWithOneCollection.watchCollection] else []
      )

      teardown(()->
        updateFromWatchedCollectionsRes=null
      )

      test("callsUpdateFromWatchedCollectionsWithFunctions", ()->
        pav = new PlayAreaView(gameState:gsmWithOneCollection)
        pav.createModel()
        JsMockito.verify(pav.model.ships.updateFromWatchedCollections)(JsHamcrest.Matchers.func(),JsHamcrest.Matchers.func())
      )
      test("callsUpdateFromWatchedCollectionsWithComparerThatIdentifiesMatchesOnModelIdToId", ()->
        pav = new PlayAreaView(gameState:gsmWithOneCollection)
        pav.createModel()

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
        pav = new PlayAreaView(gameState:gsmWithOneCollection)
        pav.createModel()

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
        pav = new PlayAreaView(gameState:gsmWithOneCollection)
        pav.createModel()

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
        pav = new PlayAreaView(gameState:gsmWithOneCollection)

        pav.createModel()

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

