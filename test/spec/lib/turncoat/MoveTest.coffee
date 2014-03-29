require(["isolate", "isolateHelper"], (Isolate, Helper)->

)

define(["isolate!lib/turncoat/Move", "jsMockito", "jsHamcrest", "chai"], (Move, jm, h, c)->
  mocks = window.mockLibrary["lib/turncoat/Move"]
  m = h.Matchers
  a = c.assert
  v = jm.Verifiers
  suite("Move", ()->
    suite("initialise", ()->
      test("Actions not specified in constructor - creates new actions as Backbone Collection", ()->
        move = new Move()
        a.instanceOf(move.get("actions"), Backbone.Collection)
        a.equal(0, move.get("actions").length)
      )
      test("Actions specified in constructor - leaves actions as that specified", ()->
        acts = {}
        move = new Move(actions:acts)
        a.equal(acts, move.get("actions"))
      )
    )
  )


)

