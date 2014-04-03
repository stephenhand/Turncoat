require(["isolate", "isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("UI/board/AssetSelectionOverlayViewModel","UI/board/AssetSelectionOverlayView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      class ret
      ret
    )
  )
)

define(["isolate!UI/board/AssetSelectionOverlayView", "jsMockito", "jsHamcrest", "chai"], (AssetSelectionOverlayView, jm, h, c)->
  mocks = window.mockLibrary["UI/board/AssetSelectionOverlayView"]
  m = h.Matchers
  a = c.assert
  v = jm.Verifiers
  suite("AssetSelectionOverlayView", ()->
    suite("setModel", ()->
      test("Model not set already - sets as new AssetViewModel", ()->
        asov = new AssetSelectionOverlayView()
        asov.createModel()
        a.instanceOf(asov.model, mocks["UI/board/AssetSelectionOverlayViewModel"])
      )
      test("Model set already - does nothing", ()->
        asov = new AssetSelectionOverlayView()
        m = {}
        asov.model = m
        asov.createModel()
        a.equal(asov.model, m)
      )
    )
  )


)

