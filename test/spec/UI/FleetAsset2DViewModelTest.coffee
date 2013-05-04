define(['isolate!UI/FleetAsset2DViewModel'], (FleetAsset2DViewModel)->
  suite("FleetAsset2DViewModel", ()->
    suite("constructor", ()->
      mockModel = {position:{}}
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
          model:mockModel.position
          attributes:[
            "x"
            "y"
            "bearing"
          ]
        )))
      )
      teardown(()->
        FleetAsset2DViewModel.prototype.watch = origWatch
      )
    )
  )


)

