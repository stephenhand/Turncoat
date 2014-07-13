require(["isolate", "isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("lib/turncoat/GameStateModel","state/FleetAsset", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      actual
    )
  )
  Isolate.mapAsFactory("lib/turncoat/TypeRegistry","state/FleetAsset", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      registerType:JsMockito.mockFunction()
    )
  )
)

define(["isolate!state/FleetAsset", "matchers", "operators", "assertThat", "jsMockito", "verifiers"], (FleetAsset, m, o, a, jm, v)->
  mocks = window.mockLibrary["state/FleetAsset"]
  suite("FleetAsset", ()->
    suite("getOwningPlayer", ()->
      fa = null

      class MockPlayer
      setup(()->
        mocks["lib/turncoat/TypeRegistry"]["Player"]=MockPlayer
        mocks["lib/turncoat/TypeRegistry"]["Player"]=MockPlayer
        fa = new FleetAsset()
      )
      test("Object whose type is registered as 'Player' is part of ownership chain - returns that object", ()->
        p = new MockPlayer()
        fa.getOwnershipChain = jm.mockFunction()
        jm.when(fa.getOwnershipChain)(m.anything()).then(()->
          [{},{},{}, p, {}, {}]
        )
        a(fa.getOwningPlayer({}), p)
      )
      test("No such object is part of ownership chain - returns null", ()->
        fa.getOwnershipChain = jm.mockFunction()
        jm.when(fa.getOwnershipChain)(m.anything()).then(()->
          [{},{},{}, {}, {}, {}]
        )
        a(fa.getOwningPlayer({}), m.nil())
      )
      test("Several such object part of ownership chain - returns first", ()->
        p1 = new MockPlayer()
        p2 = new MockPlayer()
        p3 = new MockPlayer()
        p4 = new MockPlayer()
        fa.getOwnershipChain = jm.mockFunction()
        jm.when(fa.getOwnershipChain)(m.anything()).then(()->
          [{}, p3, p4, {}, p1, p2]
        )
        a(fa.getOwningPlayer({}), p3)
      )
    )
    suite("getAvailableActions", ()->
      fa = null
      rb = null
      ruleEntry = null
      rule = null
      setup(()->
        fa = new FleetAsset()
        rule =
          getPermittedActionsForAsset : jm.mockFunction()
        jm.when(rule.getPermittedActionsForAsset)().then(()->
          "AVAILABLE_ACTIONS"
        )
        ruleEntry =
          getRule : jm.mockFunction()
        jm.when(ruleEntry.getRule)().then(()->
          rule
        )
        rb =
          lookUp : jm.mockFunction()
        jm.when(rb.lookUp)(m.string()).then((path)->
          if path is "ships.permitted-actions" then ruleEntry
        )
        fa._root =
          getRuleBook:()->
            rb
      )
      test("Looks up ships.permitted-actions in the game's rulebook", ()->
        fa.getAvailableActions()
        jm.verify(rb.lookUp)("ships.permitted-actions")
      )
      test("Gets rule from looke up entry, calls getAvailableActions on it and returns result", ()->
        acts = fa.getAvailableActions()
        jm.verify(ruleEntry.getRule)()
        jm.verify(rule.getPermittedActionsForAsset)()
        a(acts, "AVAILABLE_ACTIONS")
      )
      test("Rule entry lookup fails - throws", ()->
        jm.when(rb.lookUp)(m.string()).then(()->)
        a(fa.getAvailableActions, m.raisesAnything())
      )
    )
  )


)

