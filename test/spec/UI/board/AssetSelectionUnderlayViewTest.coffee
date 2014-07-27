require(["isolate", "isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("UI/board/AssetSelectionOverlayViewModel","UI/board/AssetSelectionUnderlayView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      class ret
      ret
    )
  )
)

define(["isolate!UI/board/AssetSelectionUnderlayView", "matchers", "operators", "assertThat", "jsMockito", "verifiers"],(AssetSelectionUnderlayView, m, o, a, jm, v)->
  mocks = window.mockLibrary["UI/board/AssetSelectionUnderlayView"]
  suite("AssetSelectionUnderlayView", ()->
    suite("createModel", ()->
      test("Model not set already - sets as new AssetViewModel", ()->
        asov = new AssetSelectionUnderlayView()
        asov.createModel()
        a(asov.model, m.instanceOf(mocks["UI/board/AssetSelectionOverlayViewModel"]))
      )
      test("Model set already - does nothing", ()->
        asov = new AssetSelectionUnderlayView()
        m = {}
        asov.model = m
        asov.createModel()
        a(asov.model, m)
      )
    )
  )


)

