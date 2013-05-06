define(['isolate!UI/FleetAsset2DViewModel'], (FleetAsset2DViewModel)->
  suite("FleetAsset2DViewModel", ()->
    suite("constructor", ()->
      mockModel = {
        get:JsMockito.mockFunction()
        position:{}
      }
      JsMockito.when(mockModel.get)(JsHamcrest.Matchers.anything()).then(
        (att)->
          switch att
            when "uuid"
              "MOCKMODEL_UUID"
            when "position"
              {}
      )
      origWatch = FleetAsset2DViewModel.prototype.watch
      setup(()->
        FleetAsset2DViewModel.prototype.watch = JsMockito.mockFunction()
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
        chai.assert.equal(fa2dvm.get("uuid"),"MOCKMODEL_UUID")
      )
      teardown(()->
        FleetAsset2DViewModel.prototype.watch = origWatch
      )
    )
    suite("updateFromFleetAsset", ()->
      test("differentUuid_DoesNotUpdateUuid", ()->

      )
    )

  )


)

