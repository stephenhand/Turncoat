require(["isolate", "isolateHelper"], (Isolate, Helper)->

)

define(["isolate!lib/turncoat/Action", "matchers", "operators", "assertThat", "jsMockito", "verifiers"], (Action, m, o, a, jm, v)->
  mocks = window.mockLibrary["lib/turncoat/Action"]
  suite("Action", ()->
    suite("initialise", ()->
      test("Events not specified in constructor - creates new events as Backbone Collection", ()->
        act = new Action()
        a(act.get("events"), m.instanceOf(Backbone.Collection))
        a(0, act.get("events").length)
      )
      test("Events specified in constructor - leaves events as that specified", ()->
        evts = {}
        act = new Action(events:evts)
        a(evts, act.get("events"))
      )
    )
    suite("reset", ()->
      test("Events set - resets them", ()->
        act = new Action()
        act.get("events").reset = jm.mockFunction()
        act.reset()
        jm.verify(act.get("events").reset)()
      )
      test("Events unset - throws", ()->
        act = new Action()
        act.unset("events")
        a(()->
          act.reset()
        ,
          m.raisesAnything()
        )
      )
    )
  )


)

