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
  Isolate.mapAsFactory("UI/BaseViewModelCollection","UI/PlayAreaView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      mockBaseViewModelCollection = (data)->
        mockConstructedBVMC = new Backbone.Collection(data)
        mockConstructedBVMC.watch = JsMockito.mockFunction()
        JsMockito.when(mockConstructedBVMC.watch)(JsHamcrest.Matchers.anything()).then((collections)->
          mockConstructedBVMC.watchedCollections = collections
        )
        mockConstructedBVMC
      mockBaseViewModelCollection
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

      gsmWithOneCollectionThreeItems = JsMockito.mock(GameStateModel)
      gsmWithOneCollectionThreeItems.watchCollection = new Backbone.Collection([
        new mocks["state/FleetAsset"]        
        new mocks["state/FleetAsset"]
        new mocks["state/FleetAsset"]
        
      ])
      gsmWithOneCollectionThreeItems.watchCollection.at(0).id="MOCK_FLEETASSET0_UUID"
      gsmWithOneCollectionThreeItems.watchCollection.at(1).id="MOCK_FLEETASSET1_UUID"
      gsmWithOneCollectionThreeItems.watchCollection.at(2).id="MOCK_FLEETASSET2_UUID"
      gsmWithOneCollectionThreeItems.watchCollection.at(0).cid="MOCK_FLEETASSET0_UUID"
      gsmWithOneCollectionThreeItems.watchCollection.at(1).cid="MOCK_FLEETASSET1_UUID"
      gsmWithOneCollectionThreeItems.watchCollection.at(2).cid="MOCK_FLEETASSET2_UUID"
      JsMockito.when(gsmWithOneCollectionThreeItems.searchChildren)(JsHamcrest.Matchers.anything()).then((func)->
        if gsmWithOneCollectionThreeItems.watchCollection then [gsmWithOneCollectionThreeItems.watchCollection] else []
      )


      gsmWithOneLevelTwoCollectionsThreeItems = JsMockito.mock(GameStateModel)
      gsmWithOneLevelTwoCollectionsThreeItems.watchCollection = new Backbone.Collection([
        new mocks["state/FleetAsset"]
        new mocks["state/FleetAsset"]

      ])
      gsmWithOneLevelTwoCollectionsThreeItems.otherWatchCollection = new Backbone.Collection([
        new mocks["state/FleetAsset"]
      ])
      gsmWithOneLevelTwoCollectionsThreeItems.watchCollection.at(0).id="MOCK_FLEETASSET0_UUID"
      gsmWithOneLevelTwoCollectionsThreeItems.watchCollection.at(1).id="MOCK_FLEETASSET1_UUID"
      gsmWithOneLevelTwoCollectionsThreeItems.otherWatchCollection.at(0).id="MOCK_FLEETASSET2_UUID"
      gsmWithOneLevelTwoCollectionsThreeItems.watchCollection.at(0).cid="MOCK_FLEETASSET0_UUID"
      gsmWithOneLevelTwoCollectionsThreeItems.watchCollection.at(1).cid="MOCK_FLEETASSET1_UUID"
      gsmWithOneLevelTwoCollectionsThreeItems.otherWatchCollection.at(0).cid="MOCK_FLEETASSET2_UUID"
      JsMockito.when(gsmWithOneLevelTwoCollectionsThreeItems.searchChildren)(JsHamcrest.Matchers.anything()).then((func)->
        if gsmWithOneLevelTwoCollectionsThreeItems.watchCollection then [gsmWithOneLevelTwoCollectionsThreeItems.watchCollection, gsmWithOneLevelTwoCollectionsThreeItems.otherWatchCollection] else []
      )

      gsmWithThreeCollectionsFiveItemsThreeValid = JsMockito.mock(GameStateModel)
      gsmWithThreeCollectionsFiveItemsThreeValid.watchCollection = new Backbone.Collection([
        new mocks["state/FleetAsset"]
        new Backbone.Model()
        new mocks["state/FleetAsset"]
      ])
      gsmWithThreeCollectionsFiveItemsThreeValid.otherCollection = new Backbone.Collection([
        new Backbone.Model()
        new mocks["state/FleetAsset"]
        new mocks["state/FleetAsset"]
        new Backbone.Model()
      ])
      gsmWithThreeCollectionsFiveItemsThreeValid.thirdCollection = new Backbone.Collection([
        new mocks["state/FleetAsset"]
      ])

      gsmWithThreeCollectionsFiveItemsThreeValid.watchCollection.at(0).id="MOCK_FLEETASSET0_UUID"
      gsmWithThreeCollectionsFiveItemsThreeValid.watchCollection.at(2).id="MOCK_FLEETASSET1_UUID"
      gsmWithThreeCollectionsFiveItemsThreeValid.otherCollection.at(1).id="MOCK_FLEETASSET2_UUID"
      gsmWithThreeCollectionsFiveItemsThreeValid.otherCollection.at(2).id="MOCK_FLEETASSET3_UUID"
      gsmWithThreeCollectionsFiveItemsThreeValid.thirdCollection.at(0).id="MOCK_FLEETASSET4_UUID"
      gsmWithThreeCollectionsFiveItemsThreeValid.watchCollection.at(0).cid="MOCK_FLEETASSET0_UUID"
      gsmWithThreeCollectionsFiveItemsThreeValid.watchCollection.at(2).cid="MOCK_FLEETASSET1_UUID"
      gsmWithThreeCollectionsFiveItemsThreeValid.otherCollection.at(1).cid="MOCK_FLEETASSET2_UUID"
      gsmWithThreeCollectionsFiveItemsThreeValid.otherCollection.at(2).cid="MOCK_FLEETASSET3_UUID"
      gsmWithThreeCollectionsFiveItemsThreeValid.thirdCollection.at(0).cid="MOCK_FLEETASSET4_UUID"
      JsMockito.when(gsmWithThreeCollectionsFiveItemsThreeValid.searchChildren)(JsHamcrest.Matchers.anything()).then((func)->
        if gsmWithThreeCollectionsFiveItemsThreeValid.watchCollection then [gsmWithThreeCollectionsFiveItemsThreeValid.watchCollection, gsmWithThreeCollectionsFiveItemsThreeValid.otherCollection, gsmWithThreeCollectionsFiveItemsThreeValid.thirdCollection] else []
      )

      test("createsFleetAsset2DViewModelsWatchingSingleCollectionSingleItems", ()->
        pav = new PlayAreaView(gameState:gsmWithOneCollection)
        pav.createModel()
        chai.assert.equal(pav.model.ships.length, 1)
        chai.assert.equal(pav.model.ships.at(0).get("modelId"),"MOCK_FLEETASSET0_UUID")
      )
      test("createsFleetAsset2DViewModelsWatchingSingleCollectionThreeitems", ()->
        pav = new PlayAreaView(gameState:gsmWithOneCollectionThreeItems)
        pav.createModel()
        chai.assert.equal(pav.model.ships.length, 3)
        chai.assert.equal(pav.model.ships.at(0).get("modelId"),"MOCK_FLEETASSET0_UUID")
        chai.assert.equal(pav.model.ships.at(1).get("modelId"),"MOCK_FLEETASSET1_UUID")
        chai.assert.equal(pav.model.ships.at(2).get("modelId"),"MOCK_FLEETASSET2_UUID")
      )
      test("createsFleetAsset2DViewModelsWatchingThreeCollectionsIrrelevantItems", ()->
        pav = new PlayAreaView(gameState:gsmWithThreeCollectionsFiveItemsThreeValid)
        pav.createModel()
        chai.assert.equal(pav.model.ships.length, 5)
        chai.assert.equal(pav.model.ships.at(0).get("modelId"),"MOCK_FLEETASSET0_UUID")
        chai.assert.equal(pav.model.ships.at(1).get("modelId"),"MOCK_FLEETASSET1_UUID")
        chai.assert.equal(pav.model.ships.at(2).get("modelId"),"MOCK_FLEETASSET2_UUID")
        chai.assert.equal(pav.model.ships.at(3).get("modelId"),"MOCK_FLEETASSET3_UUID")
        chai.assert.equal(pav.model.ships.at(4).get("modelId"),"MOCK_FLEETASSET4_UUID")
      )
    )
  )


)

