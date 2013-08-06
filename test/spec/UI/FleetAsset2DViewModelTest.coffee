require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("AppState", 'UI/FleetAsset2DViewModel', (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      on:JsMockito.mockFunction()
      get:(key)->
        if key is 'game'
          state:
            searchGameStateModels:(func)->
              if func(
                id:"MOCKMODEL_UUID"
              )
                mockModel =
                  id:"MOCKMODEL_UUID"
                  get:JsMockito.mockFunction()
                  on:JsMockito.mockFunction()

                mockPos =
                  get:JsMockito.mockFunction()
                  on:JsMockito.mockFunction()

                JsMockito.when(mockModel.get)(JsHamcrest.Matchers.anything()).then(
                  (att)->
                    switch att
                      when "position"
                        mockPos
                )

                JsMockito.when(mockPos.get)(JsHamcrest.Matchers.anything()).then(
                  (att)->
                    switch att
                      when "x"
                        123
                      when "y"
                        321
                      when "bearing"
                        45

                )
                [mockModel]
    )
  )
)
define(['isolate!UI/FleetAsset2DViewModel'], (FleetAsset2DViewModel)->
  mocks=window.mockLibrary['UI/FleetAsset2DViewModel']
  mockModel =
    id:"MOCKMODEL_UUID"
    get:JsMockito.mockFunction()
    on:JsMockito.mockFunction()

  mockPos =
    get:JsMockito.mockFunction()
    on:JsMockito.mockFunction()


  JsMockito.when(mockModel.get)(JsHamcrest.Matchers.anything()).then(
    (att)->
      switch att
        when "position"
          mockPos
  )

  JsMockito.when(mockPos.get)(JsHamcrest.Matchers.anything()).then(
    (att)->
      switch att
        when "x"
          123
        when "y"
          321
        when "bearing"
          45
  )
  suite("FleetAsset2DViewModel", ()->

    suite("constructor", ()->

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
      test("setsXPos", ()->
        fa2dvm = new FleetAsset2DViewModel(model:mockModel)
        chai.assert.equal(fa2dvm.get("xpx"),"123px")
      )
      test("setsYPos", ()->
        fa2dvm = new FleetAsset2DViewModel(model:mockModel)
        chai.assert.equal(fa2dvm.get("ypx"),"321px")
      )
      test("setsTransform", ()->
        fa2dvm = new FleetAsset2DViewModel(model:mockModel)
        chai.assert.equal(fa2dvm.get("transformDegrees"),"45")
      )
      teardown(()->
        FleetAsset2DViewModel.prototype.watch = origWatch
      )
    )
    suite("updateFromFleetAsset", ()->

      mockOtherModel =
        id:"MOCKMODEL_UUID2"
        get:JsMockito.mockFunction()
        on:JsMockito.mockFunction()

      test("differentmodelId_DoesNotUpdatemodelId", ()->
        fa2dvm = new FleetAsset2DViewModel(model:mockModel)
        fa2dvm.onModelUpdated(mockOtherModel)
        chai.assert.equal(fa2dvm.get("classList"),"view-model-item fleet-asset-2d")
      )
    )
  )


)

