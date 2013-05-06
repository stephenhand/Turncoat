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
      gsmWithOneCollection.watchCollection.at(0).set("uuid","MOCK_FLEETASSET0_UUID")
      JsMockito.when(gsmWithOneCollection.searchChildren)(JsHamcrest.Matchers.anything()).then((func)->
        if gsmWithOneCollection.watchCollection then [gsmWithOneCollection.watchCollection] else []
      )

      gsmWithOneCollectionThreeItems = JsMockito.mock(GameStateModel)
      gsmWithOneCollectionThreeItems.watchCollection = new Backbone.Collection([
        new mocks["state/FleetAsset"]        
        new mocks["state/FleetAsset"]
        new mocks["state/FleetAsset"]
        
      ])
      gsmWithOneCollectionThreeItems.watchCollection.at(0).set("uuid","MOCK_FLEETASSET0_UUID")
      gsmWithOneCollectionThreeItems.watchCollection.at(1).set("uuid","MOCK_FLEETASSET1_UUID")
      gsmWithOneCollectionThreeItems.watchCollection.at(2).set("uuid","MOCK_FLEETASSET2_UUID")
      JsMockito.when(gsmWithOneCollectionThreeItems.searchChildren)(JsHamcrest.Matchers.anything()).then((func)->
        if gsmWithOneCollectionThreeItems.watchCollection then [gsmWithOneCollectionThreeItems.watchCollection] else []
      )
      test("createsFleetAsset2DViewModelsWatchingSingleCollectionSingleItems", ()->
        pav = new PlayAreaView(gameState:gsmWithOneCollection)
        pav.createModel()
        chai.assert.equal(pav.model.ships.length, 1)
        chai.assert.equal(pav.model.ships.at(0).get("uuid"), "MOCK_FLEETASSET0_UUID")
      )
      test("createsFleetAsset2DViewModelsWatchingSingleCollectionThreeitems", ()->
        pav = new PlayAreaView(gameState:gsmWithOneCollectionThreeItems)
        pav.createModel()
        chai.assert.equal(pav.model.ships.length, 3)
        chai.assert.equal(pav.model.ships.at(0).get("uuid"), "MOCK_FLEETASSET0_UUID")
      )
    )
  )


)

