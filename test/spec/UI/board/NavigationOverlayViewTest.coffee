require(["isolate", "isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("UI/board/NavigationOverlayViewModel","UI/board/NavigationOverlayView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      class ret
      ret
    )
  )
)

define(["isolate!UI/board/NavigationOverlayView", "matchers", "operators", "assertThat", "jsMockito", "verifiers"],
(NavigationOverlayView, m, o, a, jm, v)->
  mocks = window.mockLibrary["UI/board/NavigationOverlayView"]
  suite("NavigationOverlayView", ()->
    suite("createModel", ()->
      test("Model not set already - sets as new AssetViewModel", ()->
        nov = new NavigationOverlayView()
        nov.createModel()
        a(nov.model, m.instanceOf(mocks["UI/board/NavigationOverlayViewModel"]))
      )
      test("Model set already - does nothing", ()->
        nov = new NavigationOverlayView()
        m = {}
        nov.model = m
        nov.createModel()
        a(nov.model, m)
      )
    )
  )
)

