require(["isolate", "isolateHelper"], (Isolate, Helper)->
)

define(["isolate!rules/v0_0_1/ships/actions/Move", "matchers", "operators", "assertThat", "jsMockito", "verifiers"],
(Move, m, o, a, jm, v)->
  mocks = window.mockLibrary["rules/v0_0_1/ships/actions/Move"]
  suite("Move", ()->
    suite("someMethod", ()->
      test("someTest", ()->
        a()
      )
    )
  )
)

