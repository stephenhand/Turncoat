require(["isolate", "isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("UI/FleetAsset2DViewModel","UI/board/FleetAssetSelectionViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      ret=Backbone.Model.extend(
        watch:JsMockito.mockFunction()
      )
      ret
    )
  )
)

define(["isolate!UI/board/FleetAssetSelectionViewModel", "jsMockito", "jsHamcrest", "chai"],
(FleetAssetSelectionViewModel, jm, h, c)->
  mocks = window.mockLibrary["UI/board/FleetAssetSelectionViewModel"]
  m = h.Matchers
  a = c.assert
  v = jm.Verifiers
  suite("FleetAssetSelectionViewModel", ()->
    suite("intialize", ()->
      setup(()->
      )
      test("Models owning player equals games current controlling player - sets 'friendly' to true", ()->
        p = {}
        fasvm = new FleetAssetSelectionViewModel(null,
          model:
            getOwningPlayer:()->
              p
          game:
            getCurrentControllingPlayer:()->
              p
        )
        a.isTrue(fasvm.get("friendly"))
      )
      test("Models owning player doesn't equal games current controlling player - sets 'friendly' to false", ()->
        fasvm = new FleetAssetSelectionViewModel(null,
          model:
            getOwningPlayer:()->
              {}
          game:
            getCurrentControllingPlayer:()->
              {}
        )
        a.isFalse(fasvm.get("friendly"))
      )
      test("No model specified - throws", ()->
        a.throw(()->
          new FleetAssetSelectionViewModel(null,
            game:
              getCurrentControllingPlayer:()->
                {}
          )
        )
      )
      test("No game specified - throws", ()->
        a.throw(()->
          fasvm = new FleetAssetSelectionViewModel(null,
            model:
              getOwningPlayer:()->
                p
          )
        )
      )
    )
  )


)

