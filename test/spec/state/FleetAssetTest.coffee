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
        jm.when(fa.getOwnershipChain)().then(()->
          [{},{},{}, p, {}, {}]
        )
        a(fa.getOwningPlayer(), p)
      )
      test("No such object is part of ownership chain - returns null", ()->
        fa.getOwnershipChain = jm.mockFunction()
        jm.when(fa.getOwnershipChain)().then(()->
          [{},{},{}, {}, {}, {}]
        )
        a(fa.getOwningPlayer(), m.nil())
      )
      test("Several such object part of ownership chain - returns first", ()->
        p1 = new MockPlayer()
        p2 = new MockPlayer()
        p3 = new MockPlayer()
        p4 = new MockPlayer()
        fa.getOwnershipChain = jm.mockFunction()
        jm.when(fa.getOwnershipChain)().then(()->
          [{}, p3, p4, {}, p1, p2]
        )
        a(fa.getOwningPlayer(), p3)
      )
    )
    suite("getAvailableActions", ()->
      fa = null
      rb = null
      ruleEntry = null
      rule = null
      game = null
      setup(()->
        fa = new FleetAsset()
        rule =
          getPermittedActionsForAsset : jm.mockFunction()
        jm.when(rule.getPermittedActionsForAsset)().then(()->
          "AVAILABLE_ACTIONS"
        )
        ruleEntry =
          getActionRules : jm.mockFunction()
        jm.when(ruleEntry.getActionRules)().then(()->
          rule
        )
        rb =
          lookUp : jm.mockFunction()
        jm.when(rb.lookUp)(m.string()).then((path)->
          if path is "ships.permitted-actions" then ruleEntry
        )
        game =
          getRuleBook:()->
            rb
        fa.getRoot = ()->
          game
      )
      test("Looks up ships.permitted-actions in the game's rulebook", ()->
        fa.getAvailableActions()
        jm.verify(rb.lookUp)("ships.permitted-actions")
      )
      test("Gets rule from looke up entry, calls getPermittedActionsForAsset on it with itselef and game and returns result", ()->
        acts = fa.getAvailableActions()
        jm.verify(ruleEntry.getActionRules)()
        jm.verify(rule.getPermittedActionsForAsset)(fa, game)
        a(acts, "AVAILABLE_ACTIONS")
      )
      test("Rule entry lookup fails - throws", ()->
        jm.when(rb.lookUp)(m.string()).then(()->)
        a(fa.getAvailableActions, m.raisesAnything())
      )
    )
    suite("getCurrentTurnEvents", ()->
      fa = null
      setup(()->
        fa = new FleetAsset()
        fa.getRoot = jm.mockFunction()
      )
      test("No owning game - throws", ()->
        a(
          ()->
            fa.getCurrentTurnEvents()
        ,
          m.raisesAnything()
        )
      )
      suite("Has owning game", ()->
        g = null
        setup(()->
          g =
            getCurrentTurnMoves:jm.mockFunction()
          jm.when(fa.getRoot)().then(()->
            g
          )
        )
        test("Game has no current turn moves - returns empty array", ()->
          jm.when(g.getCurrentTurnMoves)().then(()->
            []
          )
          a(fa.getCurrentTurnEvents(), m.empty())
        )
        test("Game has current moves but no actions - returns empty array", ()->
          jm.when(g.getCurrentTurnMoves)().then(()->
            [
              new Backbone.Model()
            ,
              new Backbone.Model()
            ,
              new Backbone.Model()
            ]
          )
          a(fa.getCurrentTurnEvents(), m.empty())
        )
        test("Game has current moves but empty actions - returns empty array", ()->
          jm.when(g.getCurrentTurnMoves)().then(()->
            [
              new Backbone.Model(
                actions:new Backbone.Collection()
              )
            ,
              new Backbone.Model(
                actions:new Backbone.Collection()
              )
            ,
              new Backbone.Model(
                actions:new Backbone.Collection()
              )
            ]
          )
          a(fa.getCurrentTurnEvents(), m.empty())
        )
      )

    )
    suite("addContext", ()->
      fa = null
      setup(()->
        fa = new FleetAsset()
      )
      test("Called with object - adds dimensions length attribute as SHIP_LENGTH", ()->
        fa.set("dimensions", new Backbone.Model(length:1337))
        ctx = {}
        fa.addContext(ctx)
        a(ctx.SHIP_LENGTH, 1337)
      )
      test("Called without object - throws", ()->
        fa.set("dimensions", new Backbone.Model(length:1337))
        a(()->
          fa.addContext()
        ,
          m.raisesAnything()
        )
      )
      test("Called when asset has no dimension - sets SHIP_LENGTH to zero", ()->

        ctx = {}
        fa.addContext(ctx)
        a(ctx.SHIP_LENGTH, 0)
      )
    )
  )


)

