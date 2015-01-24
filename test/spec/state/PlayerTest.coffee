require(["isolate", "isolateHelper"], (Isolate, Helper)->
)

define(["isolate!state/Player", "matchers", "operators", "assertThat", "jsMockito", "verifiers"],
(Player, m, o, a, jm, v)->
  mocks = window.mockLibrary["state/Player"]
  suite("Player", ()->

    suite("getCurrentTurnMoves", ()->
      p = null
      game = null
      setup(()->
        p = new Player()
        game = new Backbone.Model(
        )
        p.getRoot = jm.mockFunction()
        jm.when(p.getRoot)().then(()->
          game
        )
      )
      test("Game has no move log - returns empty array", ()->
        a(p.getCurrentTurnMoves(), m.empty())
      )
      test("Game has empty move log - returns empty array", ()->
        game.set("moveLog", new Backbone.Collection([]))
        a(p.getCurrentTurnMoves(), m.empty())
      )
      suite("Game has populated move log", ()->)
    )
  )
)

