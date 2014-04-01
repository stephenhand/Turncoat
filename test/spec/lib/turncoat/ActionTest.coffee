require(["isolate", "isolateHelper"], (Isolate, Helper)->

)

define(["isolate!lib/turncoat/Action", "jsMockito", "jsHamcrest", "chai"], (Action, jm, h, c)->
  mocks = window.mockLibrary["lib/turncoat/Action"]
  m = h.Matchers
  a = c.assert
  v = jm.Verifiers
  suite("Action", ()->
    suite("initialise", ()->
      test("Events not specified in constructor - creates new events as Backbone Collection", ()->
        act = new Action()
        a.instanceOf(act.get("events"), Backbone.Collection)
        a.equal(0, act.get("events").length)
      )
      test("Events specified in constructor - leaves events as that specified", ()->
        evts = {}
        act = new Action(events:evts)
        a.equal(evts, act.get("events"))
      )
    )
  )


)

