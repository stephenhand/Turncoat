require(["isolate", "isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("UI/board/AssetSelectionOverlayViewModel","UI/board/AssetSelectionOverlayView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      class ret
        constructor:()->
          @setNominatedAsset = JsMockito.mockFunction()
          @on = JsMockito.mockFunction()
      ret
    )
  )
)

define(["isolate!UI/board/AssetSelectionOverlayView", "matchers", "operators", "assertThat","jsMockito", "verifiers"], (AssetSelectionOverlayView, m, o, a, jm, v)->
  mocks = window.mockLibrary["UI/board/AssetSelectionOverlayView"]
  suite("AssetSelectionOverlayView", ()->
    suite("createModel", ()->
      test("Model not set already - sets as new AssetViewModel", ()->
        asov = new AssetSelectionOverlayView()
        asov.createModel()
        a(asov.model, m.instanceOf(mocks["UI/board/AssetSelectionOverlayViewModel"]))
      )
      test("Model set already - does not replace it", ()->
        asov = new AssetSelectionOverlayView()
        mod =
          on : JsMockito.mockFunction()
        asov.model = mod
        asov.createModel()
        a(asov.model, mod)
      )
      test("Binds to changes to 'nominatedAsset' property", ()->
        asov = new AssetSelectionOverlayView()
        asov.createModel()
        jm.verify(asov.model.on)("change:nominatedAsset", m.func())
      )
    )
    suite("hotspotClicked", ()->
      model = null
      asov = null
      setup(()->
        model = new Backbone.Model(
          ships:new Backbone.Collection([
            UUID:
              toString:()->
                "MOCK_SHIP_ID_1"
          ,
            UUID:
              toString:()->
                "MOCK_SHIP_ID_2"
          ,
            new Backbone.Model(
              UUID:
                toString:()->
                  "MOCK_SHIP_ID_3"
            )
          ,
            UUID:
              toString:()->
                "MOCK_SHIP_ID_4"
          ,
            UUID:
              toString:()->

          ])
        )
        model.setNominatedAsset = JsMockito.mockFunction()
        asov = new AssetSelectionOverlayView()
        asov.model = model
      )
      suite("event has target with asset-id attribute matching UUID in ships collection", ()->
        event = null
        setup(()->
          event =
            currentTarget:
              getAttribute:jm.mockFunction()
          jm.when(event.currentTarget.getAttribute)(m.anything()).then((key)->
            if key is "asset-id" then "MOCK_SHIP_ID_3"
          )
        )
        test("'nominatedAsset' not set - Sets model's 'nominatedAsset' to be ship represented by clicked element's asset-id", ()->
          asov.hotspotClicked(event)
          jm.verify(model.setNominatedAsset)(model.get("ships").at(2))
        )
        test("'nominatedAsset' set - Still sets model's 'nominatedAsset' to be ship represented by clicked element's asset-id", ()->
          model.set("nominatedAsset",{})
          asov.hotspotClicked(event)
          jm.verify(model.setNominatedAsset)(model.get("ships").at(2))
        )
      )
      test("event not set - throws", ()->
        a(
          ()->asov.hotspotClicked()
        ,
          m.raisesAnything()
        )
      )
      test("event currentTarget not set - throws", ()->
        a(
          ()->asov.hotspotClicked({})
        ,
          m.raisesAnything()
        )
      )
      test("event currentTarget getAttribute not callable - throws", ()->
        a(
          ()->asov.hotspotClicked(
            currentTarget:
              getAttribute:{}
          )
        ,
          m.raisesAnything()
        )
      )
      test("nominatedAsset not set and event currentTarget asset-id not matching UUID ships collection - sets nominated asset to nil", ()->
        asov.hotspotClicked(
          currentTarget:
            getAttribute:()->
              "SOMETHING ELSE"
        )

        jm.verify(model.setNominatedAsset)(m.nil())
      )
      test("nominatedAsset set and event currentTarget asset-id not matching UUID in ships collection - calls set setNominatedAsset with nil", ()->
        model.set("nominatedAsset",{})
        asov.hotspotClicked(
          currentTarget:
            getAttribute:()->
              "SOMETHING ELSE"
        )

        jm.verify(model.setNominatedAsset)(m.nil())
      )
      test("Does not match undefined UUID toString output with undefined asset-id", ()->
        model.set("nominatedAsset",{})
        asov.hotspotClicked(
          currentTarget:
            getAttribute:()->
        )

        jm.verify(model.setNominatedAsset)(m.nil())
      )

    )
  )


)

