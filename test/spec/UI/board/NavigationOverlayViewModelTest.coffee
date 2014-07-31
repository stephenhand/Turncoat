require(["isolate", "isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("UI/board/NominatedAssetOverlayViewModel","UI/board/NavigationOverlayViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      class ret extends Backbone.Model
        constructor:()->
          @superSetGame = JsMockito.mockFunction()
        setGame:(game)->
          @superSetGame(game)
        initialize:()->
      ret
    )
  )
)

define(["isolate!UI/board/NavigationOverlayViewModel", "matchers", "operators", "assertThat", "jsMockito", "verifiers"],
(NavigationOverlayViewModel, m, o, a, jm, v)->
  mocks = window.mockLibrary["UI/board/NavigationOverlayViewModel"]
  suite("NavigationOverlayViewModel", ()->
    suite("setGame", ()->
      game = null
      ghost = null
      setup(()->
        ghost = {}
        game =
          ghost:jm.mockFunction()
        jm.when(game.ghost)().then(()->ghost)
      )
      test("calls parent implementation with ghost of game provided", ()->
        novm = new NavigationOverlayViewModel()
        novm.setGame(game)
        jm.verify(game.ghost)()
        jm.verify(novm.superSetGame)(ghost)
      )
    )
  )
)

