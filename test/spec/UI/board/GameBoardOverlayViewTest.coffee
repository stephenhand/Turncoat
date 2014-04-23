require(["isolate", "isolateHelper"], (Isolate, Helper)->

)

define(["isolate!UI/board/GameBoardOverlayView", "jsMockito", "jsHamcrest", "chai"], (GameBoardOverlayView, jm, h, c)->
  mocks = window.mockLibrary["UI/board/GameBoardOverlayView"]
  m = h.Matchers
  a = c.assert
  v = jm.Verifiers
  suite("GameBoardOverlayView", ()->
    model = null
    suite("activate", ()->
      setup(()->
        model=
          setGame:jm.mockFunction()
      )
      test("Model not set - throws", ()->
        game = {}
        gbov = new GameBoardOverlayView()
        a.throw(()->gbov.activate(game))
      )
      test("Model has not 'setGame' method - throws", ()->
        game = {}
        gbov = new GameBoardOverlayView()
        gbov.model = {}
        a.throw(()->gbov.activate(game))
      )
      test("Model has not 'setGame' method - throws", ()->
        game = {}
        gbov = new GameBoardOverlayView()
        gbov.model = {}
        a.throw(()->gbov.activate(game))
      )
    )
  )


)

