require(["isolate", "isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("UI/board/NominatedAssetOverlayViewModel","UI/board/NavigationOverlayViewModel", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      class ret extends Backbone.Model
        constructor:()->
          super()
          @superSetGame = JsMockito.mockFunction()
        setGame:(game)->
          @superSetGame(game)
        getAsset:()->
        initialize:()->
      ret
    )
  )
)

define(["isolate!UI/board/NavigationOverlayViewModel", "matchers", "operators", "assertThat", "jsMockito", "verifiers", "backbone"],
(NavigationOverlayViewModel, m, o, a, jm, v, Backbone)->
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
    suite("updatePreview", ()->
      novm = null
      nominated = null
      setup(()->
        novm = new NavigationOverlayViewModel()
        nominated = new Backbone.Model()
        nominated.calculateClosestMoveAction = jm.mockFunction()
        novm.getAsset = jm.mockFunction()
        jm.when(novm.getAsset)().then(()->nominated)
      )
      test("Calls calculateClosestMoveAction on move rule with nominatedAsset, with coordinates", ()->
        novm.updatePreview(1337, 666)
        jm.verify(nominated.calculateClosestMoveAction)(1337, 666)
      )
      test("no nominated asset - throws", ()->
        jm.when(novm.getAsset)().then(()->)
        a(()->
            novm.updatePreview(1337, 666)
        ,
          m.raisesAnything()
        )
      )
    )
  )
)

