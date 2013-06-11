define(['isolate!UI/FleetAsset2DViewModel'], (FleetAsset2DViewModel)->
  suite("FleetAsset2DViewModel", ()->
    suite("constructor", ()->
      mockModel =
        id:"MOCKMODEL_UUID"
        get:JsMockito.mockFunction()

      JsMockito.when(mockModel.get)(JsHamcrest.Matchers.anything()).then(
        (att)->
          switch att
            when "position"
              {}
      )
      origWatch = FleetAsset2DViewModel.prototype.watch
      setup(()->
        FleetAsset2DViewModel.prototype.watch = JsMockito.mockFunction()
      )
      test("setsFleetAssetFromOptions", ()->
        fa2dvm = new FleetAsset2DViewModel(model:mockModel)
        #chai.assert.equal(fa2dvm.fleetAsset)
      )
      test("watchesModel", ()->
        fa2dvm = new FleetAsset2DViewModel(model:mockModel)
        JsMockito.verify(fa2dvm.watch)(JsHamcrest.Matchers.hasItem(JsHamcrest.Matchers.equivalentMap(
          model:mockModel
          attributes:[
            "position"
          ]
        )))
      )
      test("watchesModelPosition", ()->
        fa2dvm = new FleetAsset2DViewModel(model:mockModel)
        JsMockito.verify(fa2dvm.watch)(JsHamcrest.Matchers.hasItem(JsHamcrest.Matchers.equivalentMap(
          model:mockModel.get("position")
          attributes:[
            "x"
            "y"
            "bearing"
          ]
        )))
      )
      test("uuidSetFromModel", ()->
        fa2dvm = new FleetAsset2DViewModel(model:mockModel)
        chai.assert.equal(fa2dvm.get("modelId"),"MOCKMODEL_UUID")
      )
      test("setsClassList", ()->
        fa2dvm = new FleetAsset2DViewModel(model:mockModel)
        chai.assert.equal(fa2dvm.get("classList"),"view-model-item fleet-asset-2d")
      )
      teardown(()->
        FleetAsset2DViewModel.prototype.watch = origWatch
      )
    )
    suite("updateFromFleetAsset", ()->

      mockModel =
        id:"MOCKMODEL_UUID"
        get:JsMockito.mockFunction()
        on:JsMockito.mockFunction()

      JsMockito.when(mockModel.get)(JsHamcrest.Matchers.anything()).then(
        (att)->
          switch att
            when "position"
              on:JsMockito.mockFunction()
      )
      mockOtherModel =
        id:"MOCKMODEL_UUID2"
        get:JsMockito.mockFunction()
        on:JsMockito.mockFunction()

      JsMockito.when(mockModel.get)(JsHamcrest.Matchers.anything()).then(
        (att)->
          switch att
            when "position"
              on:JsMockito.mockFunction()
      )
      test("differentmodelId_DoesNotUpdatemodelId", ()->
        fa2dvm = new FleetAsset2DViewModel(model:mockModel)
        fa2dvm.onModelUpdated(mockOtherModel)
      )
    )

  )


)

