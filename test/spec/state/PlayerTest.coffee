require(["isolate", "isolateHelper"], (Isolate, Helper)->
)

define(["isolate!state/Player", "matchers", "operators", "assertThat", "jsMockito", "verifiers", 'lib/turncoat/Constants'],
(Player, m, o, a, jm, v, Constants)->
  mocks = window.mockLibrary["state/Player"]
  suite("Player", ()->

    suite("getCurrentTurnMoves", ()->
      p = null
      game = null
      setup(()->
        p = new Player()
        p.set("user", new Backbone.Model(
          userId:"MOCK_USER"
        ))
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
      test("Game has move log with no user moves - returns empty array", ()->
        game.set("moveLog", new Backbone.Collection([
          {}
        ,
          {}
        ]))
        a(p.getCurrentTurnMoves(), m.empty())
      )
      test("Game has move log with no moves by the user attached to this player - returns empty array", ()->
        game.set("moveLog", new Backbone.Collection([
          userId:"NOT_MOCK_USER"
        ,
          userId:"ALSO_NOT_MOCK_USER"
        ]))
        a(p.getCurrentTurnMoves(), m.empty())
      )
      test("Game has move log with moves by the user attached to this player only prior to new turn starting - returns empty array", ()->
        game.set("moveLog", new Backbone.Collection([
          userId:"NOT_MOCK_USER"
        ,
          userId:"ALSO_NOT_MOCK_USER"
        ,
          type:Constants.MoveTypes.NEW_TURN
        ,
          userId:"MOCK_USER"
        ,
          userId:"NOT_MOCK_USER"
        ,
          userId:"MOCK_USER"
        ]))
        a(p.getCurrentTurnMoves(), m.empty())
      )
      test("Game has move log with moves by the user attached to this player after new turn starting - returns any moves for that user after the last new turn, most recent first", ()->
        game.set("moveLog", new Backbone.Collection([
          userId:"MOCK_USER"
        ,
          userId:"NOT_MOCK_USER"
        ,
          userId:"MOCK_USER"
        ,
          type:Constants.MoveTypes.NEW_TURN
        ,
          userId:"ALSO_NOT_MOCK_USER"
        ,
          userId:"MOCK_USER"
        ]))
        res = p.getCurrentTurnMoves()
        a(res.length, 2)
        a(res[0], game.get("moveLog").get(1))
        a(res[1], game.get("moveLog").get(2))
      )
    )
  )
)

