require(["isolate", "isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("UI/board/NavigationOverlayViewModel","UI/board/NavigationOverlayView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      class ret
      ret
    )
  )
  Isolate.mapAsFactory("lib/2D/SVGTools","UI/board/NavigationOverlayView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      {}
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
        mo = {}
        nov.model = mo
        nov.createModel()
        a(nov.model, mo)
      )
    )
    suite("navigationMouseMove", ()->
      nov = null
      setup(()->
        nov = new NavigationOverlayView()
        nov.model =
          updatePreview:jm.mockFunction()
        mocks["lib/2D/SVGTools"].pixelCoordsToSVGUnits = jm.mockFunction()
        jm.when(mocks["lib/2D/SVGTools"].pixelCoordsToSVGUnits)(m.anything(),m.anything(),m.anything()).then(()->
          x:1337
          y:666
        )
      )
      test("Converts event offset X and Y coordinates using pixelCoordsToSVGUnits", ()->
        ele = {}
        nov.navigationMouseMove(
          offsetX:133
          offsetY:66
          target:ele
        )
        jm.verify(mocks["lib/2D/SVGTools"].pixelCoordsToSVGUnits)(ele,133,66)
      )
      test("Calls model.updatePreview with returned coordinates", ()->
        ele = {}
        nov.navigationMouseMove(
          offsetX:133
          offsetY:66
          target:ele
        )
        jm.verify(nov.model.updatePreview)(1337,666)
      )
      test("Model not set - throws", ()->
        a(()->
          nov.navigationMouseMove(
            offsetX:133
            offsetY:66
            target:ele
          )
        ,
          m.raisesAnything()
        )
      )
    )
  )
)

