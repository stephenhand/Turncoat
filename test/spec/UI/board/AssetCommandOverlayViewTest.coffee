require(["isolate", "isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("UI/board/AssetCommandOverlayViewModel","UI/board/AssetCommandOverlayView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      class ret
        constructor:()->
          na =
            on : JsMockito.mockFunction()
          @get=(key)->
            if key is "nominatedAssets"
              na
      ret
    )
  )
)

define(["isolate!UI/board/AssetCommandOverlayView", "matchers", "operators", "assertThat", "jsMockito", "verifiers"],
(AssetCommandOverlayView, m, o, a, jm, v)->
  mocks = window.mockLibrary["UI/board/AssetCommandOverlayView"]
  suite("AssetCommandOverlayView", ()->
    suite("createModel", ()->
      test("Model not set already - sets as new AssetCommandOverlayViewModel", ()->
        acov = new AssetCommandOverlayView()
        acov.createModel()
        a(acov.model, m.instanceOf(mocks["UI/board/AssetCommandOverlayViewModel"]))
      )
      test("Model set already - does not replace it", ()->
        acov = new AssetCommandOverlayView()
        mod =
          on : JsMockito.mockFunction()
        acov.model = mod
        acov.createModel()
        a(acov.model, mod)
      )
      test("Binds to changes to 'nominatedAssets' property", ()->
        acov = new AssetCommandOverlayView()
        acov.createModel()
        jm.verify(acov.model.get("nominatedAssets").on)("add", m.func())
      )
    )
  )
)

