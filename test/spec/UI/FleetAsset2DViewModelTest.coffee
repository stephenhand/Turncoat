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

                JsMockito.when(mockModel.get)(m.anything()).then(
                  (att)->
                    switch att
                      when "position"
                        mockPos
                )

                JsMockito.when(mockPos.get)(m.anything()).then(
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
define(["isolate!UI/FleetAsset2DViewModel", "matchers", "operators", "assertThat", "jsMockito", "verifiers"], (FleetAsset2DViewModel, m, o, a, jm, v)->
  mocks=window.mockLibrary["UI/FleetAsset2DViewModel"]
  mockModel =
    id:"MOCKMODEL_UUID"
    get:jm.mockFunction()
    on:jm.mockFunction()

  mockPos =
    get:jm.mockFunction()
    on:jm.mockFunction()
  mockDim =
    get:jm.mockFunction()
    on:jm.mockFunction()


  jm.when(mockModel.get)(m.anything()).then(
    (att)->
      switch att
        when "position"
          mockPos
        when "dimensions"
          mockDim
  )

  jm.when(mockPos.get)(m.anything()).then(
    (att)->
      switch att
        when "x"
          123
        when "y"
          321
        when "bearing"
          45
  )
  jm.when(mockDim.get)(m.anything()).then(
    (att)->
      switch att
        when "length"
          1337
        when "width"
          666
  )
  suite("FleetAsset2DViewModel", ()->

    suite("constructor", ()->

      origWatch = FleetAsset2DViewModel.prototype.watch
      setup(()->
        FleetAsset2DViewModel.prototype.watch = jm.mockFunction()
      )
      test("watches model", ()->
        fa2dvm = new FleetAsset2DViewModel(null, model:mockModel)
        jm.verify(fa2dvm.watch)(m.hasItem(m.equivalentMap(
          model:mockModel
          attributes:[
            "position"
          ]
        )))
      )
      test("Watches model position", ()->
        fa2dvm = new FleetAsset2DViewModel(null, model:mockModel)
        jm.verify(fa2dvm.watch)(m.hasItem(m.equivalentMap(
          model:mockModel.get("position")
          attributes:[
            "x"
            "y"
            "bearing"
          ]
        )))
      )
      test("Sets ClassList", ()->
        fa2dvm = new FleetAsset2DViewModel(null, model:mockModel)
        a(fa2dvm.get("classList"),"view-model-item fleet-asset-2d")
      )
      test("Sets XPos", ()->
        fa2dvm = new FleetAsset2DViewModel(null, model:mockModel)
        a(fa2dvm.get("xpx"),"123")
      )
      test("Sets YPos", ()->
        fa2dvm = new FleetAsset2DViewModel(null, model:mockModel)
        a(fa2dvm.get("ypx"),"321")
      )
      test("Sets length", ()->
        fa2dvm = new FleetAsset2DViewModel(null, model:mockModel)
        a(fa2dvm.get("length"),"1337")
      )
      test("Sets width", ()->
        fa2dvm = new FleetAsset2DViewModel(null, model:mockModel)
        a(fa2dvm.get("width"),"666")
      )
      test("Sets transform", ()->
        fa2dvm = new FleetAsset2DViewModel(null, model:mockModel)
        a(fa2dvm.get("transformDegrees"),"45")
      )
      teardown(()->
        FleetAsset2DViewModel.prototype.watch = origWatch
      )
    )
    suite("updateFromFleetAsset", ()->

      mockOtherModel =
        id:"MOCKMODEL_UUID2"
        get:()->
          get:()->
        on:()->
      test("Sets XPos", ()->
        fa2dvm = new FleetAsset2DViewModel(null, model:mockModel)
        a(fa2dvm.get("xpx"),"123")
      )
      test("Sets YPos", ()->
        fa2dvm = new FleetAsset2DViewModel(null, model:mockModel)
        a(fa2dvm.get("ypx"),"321")
      )
      test("Sets transform", ()->
        fa2dvm = new FleetAsset2DViewModel(null, model:mockModel)
        a(fa2dvm.get("transformDegrees"),"45")
      )
      test("Different model id - does not update model id", ()->
        fa2dvm = new FleetAsset2DViewModel(null, model:mockModel)
        fa2dvm.onModelUpdated(mockOtherModel)
        a(fa2dvm.get("classList"),"view-model-item fleet-asset-2d")
      )
    )
  )


)

