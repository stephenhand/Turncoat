require(["isolate", "isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("UI/board/AssetSelectionOverlayViewModel","UI/board/AssetSelectionUnderlayView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      class ret
      ret
    )
  )
)

define(["isolate!UI/board/AssetSelectionUnderlayView", "jsMockito", "jsHamcrest", "chai"], (AssetSelectionUnderlayView, jm, h, c)->
  mocks = window.mockLibrary["UI/board/AssetSelectionUnderlayView"]
  m = h.Matchers
  a = c.assert
  v = jm.Verifiers
  suite("AssetSelectionUnderlayView", ()->
    suite("setModel", ()->
      test("Model not set already - sets as new AssetViewModel", ()->
        asov = new AssetSelectionUnderlayView()
        asov.createModel()
        a.instanceOf(asov.model, mocks["UI/board/AssetSelectionOverlayViewModel"])
      )
      test("Model set already - does nothing", ()->
        asov = new AssetSelectionUnderlayView()
        m = {}
        asov.model = m
        asov.createModel()
        a.equal(asov.model, m)
      )
    )
  )


)

