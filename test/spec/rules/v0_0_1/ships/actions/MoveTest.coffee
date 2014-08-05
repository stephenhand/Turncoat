require(["isolate", "isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("lib/turncoat/Action", "rules/v0_0_1/ships/actions/Move", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      Backbone.Model.extend({})
    )
  )
)

define(["isolate!rules/v0_0_1/ships/actions/Move", "matchers", "operators", "assertThat", "jsMockito", "verifiers"],
(Move, m, o, a, jm, v)->
  mocks = window.mockLibrary["rules/v0_0_1/ships/actions/Move"]
  suite("Move", ()->

    suite("getActionRules", ()->
      test("Game supplied - returns object", ()->
        a(Move.getActionRules({}), m.object())
      )
      test("Game not supplied - throws", ()->
        a(()->
          Move.getActionRules()
        ,
          m.raisesAnything())
      )
      suite("Rules object.", ()->
        rule = null
        game = null
        setup(()->
          game = {}
          rule = Move.getActionRules(game)
        )
        suite("calculateTurnActionRequired", ()->
          asset = null
          turn = null
          setup(()->
            asset = new Backbone.Model(
              id:"MOCK ASSET ID"
              position:new Backbone.Model(
                x:1
                y:1
                bearing:45
              )
            )
          )
          suite("Turn has no minimum prior move or post move", ()->
            setup(()->
              turn=  new Backbone.Model(
                name:"MOCK TURN TYPE"
                maxRotation:90,
                beforeMove:0,
                afterMove:0,
                cost:2
              )
            )
            test("Returns action object with asset id, move and turn types supplied", ()->
              ret = rule.calculateTurnActionRequired(asset, "MOCK MOVE TYPE", turn, 2, 2)
              a(ret.action, m.instanceOf(mocks["lib/turncoat/Action"]))
              a(ret.action.attributes, m.allOf(
                  m.hasMember("rule","ships.actions.move")
                  m.hasMember("turn","MOCK TURN TYPE"),
                  m.hasMember("move","MOCK MOVE TYPE"),
                  m.hasMember("asset","MOCK ASSET ID")
                )
              )
            )
            test("Requested position is within maximum rotation - returns action with asset id, move type, turn type and angle delta", ()->
              ret = rule.calculateTurnActionRequired(asset, "MOCK MOVE TYPE", turn, 2, 1)
              a(ret.action.get("rotation"), 45)
              a(ret.shortfall, 0)
            )
            test("Requested position is within maximum rotation anticlockwise - returns action with asset id, move type, turn type and angle delta", ()->
              ret = rule.calculateTurnActionRequired(asset, "MOCK MOVE TYPE", turn, 1, 0)
              a(ret.action.get("rotation"), -45)
              a(ret.shortfall, 0)
            )
            test("Requested position is outside maximum rotation - returns action with rotation at maximum rotation for turn and the shortfall in a 'shortfall' attribute", ()->
              ret = rule.calculateTurnActionRequired(asset, "MOCK MOVE TYPE", turn, 1, 2)
              a(ret.action.get("rotation"), 90)
              a(ret.shortfall, 45)
            )
            test("Requested position is outside maximum rotation anticlockwise - returns action with rotation at maximum negative rotation for turn and the shortfall in a 'shortfall' attribute", ()->
              ret = rule.calculateTurnActionRequired(asset, "MOCK MOVE TYPE", turn, 0, 1)
              a(ret.action.get("rotation"), -90)
              a(ret.shortfall, -45)
            )
          )
          suite("Turn has required prior move but no post move", ()->
            setup(()->
              asset.get("position").set("bearing", 90)
              turn=  new Backbone.Model(
                name:"MOCK TURN TYPE"
                maxRotation:90,
                beforeMove:1,
                afterMove:0,
                cost:2
              )
            )
            test("Requested position is within maximum rotation after required move - returns action with asset id, move type, turn type and angle delta", ()->
              ret = rule.calculateTurnActionRequired(asset, "MOCK MOVE TYPE", turn, 3, 2)
              a(ret.action.get("rotation"), 45)
              a(ret.shortfall, 0)
            )
            test("Requested position is within maximum rotation anticlockwise - returns action with asset id, move type, turn type and angle delta", ()->
              ret = rule.calculateTurnActionRequired(asset, "MOCK MOVE TYPE", turn, 3, 0)
              a(ret.action.get("rotation"), -45)
              a(ret.shortfall, 0)
            )
            test("Requested position is outside maximum rotation - returns action with rotation at maximum rotation for turn and the shortfall in a 'shortfall' attribute", ()->
              ret = rule.calculateTurnActionRequired(asset, "MOCK MOVE TYPE", turn, 1, 2)
              a(ret.action.get("rotation"), 90)
              a(ret.shortfall, 45)
            )
            test("Requested position is outside maximum rotation anticlockwise - returns action with rotation at maximum negative rotation for turn and the shortfall in a 'shortfall' attribute", ()->
              ret = rule.calculateTurnActionRequired(asset, "MOCK MOVE TYPE", turn, 1, 0)
              a(ret.action.get("rotation"), -90)
              a(ret.shortfall, -45)
            )
          )
        )
        suite("resolveAction",()->
          action = null
          asset = null
          checker = null
          setup(()->
            action = new Backbone.Model(
              asset:"MOCK ASSET ID"
              move:"MOCK MOVE TYPE"
            )
            action.reset=jm.mockFunction()
            asset = new Backbone.Model(
              actions:new Backbone.Collection([
                new Backbone.Model(
                  name:"move"
                  types:new Backbone.Collection([
                    new Backbone.Model(
                      name:"MOCK MOVE TYPE"
                    )
                  ])
                )
              ])
            )
            game.searchGameStateModels = jm.mockFunction()
            jm.when(game.searchGameStateModels)(m.func()).then((f)->
              checker = f
              [asset]
            )
          )
          test("Resets action.", ()->
            rule.resolveAction(action, false)
            jm.verify(action.reset)()
          )
          test("Calls searchGameStateModels on game to locate asset", ()->
            rule.resolveAction(action, false)
            jm.verify(game.searchGameStateModels)(m.func())
          )
          suite("searchGameStateModels checker function", ()->
            test("Returns true if passed a Backbone Model with an ID same as that specified in action's asset attribute", ()->
              a(checker(
                get:(key)->
                  if key is "id" then "MOCK ASSET ID"
              ), true)
            )
            test("Returns false otherwise", ()->
              a(checker(
                get:(key)->
                  if key is "id" then "NOT MOCK ASSET ID"
              ), false)
              a(checker(
                get:(key)->
              ), false)
              a(checker({}), false)
              a(checker(), false)
            )
          )
          test("searchGameStateModels returns no asset - throws", ()->
            jm.when(game.searchGameStateModels)(m.func()).then((f)->
              []
            )
            a(()->
              rule.resolveAction(action, false)
            ,
              m.raisesAnything()
            )
          )
          test("searchGameStateModels returns multiple assets - throws", ()->
            jm.when(game.searchGameStateModels)(m.func()).then((f)->
              [{},{}]
            )
            a(()->
              rule.resolveAction(action, false)
            ,
              m.raisesAnything()
            )
          )
          test("asset located has no actions - throws", ()->
            asset.unset("actions")
            a(()->
              rule.resolveAction(action, false)
            ,
              m.raisesAnything()
            )
          )
          test("asset located has actions but no move actions - throws", ()->
            asset.set("actions", new Backbone.Collection([
              name:"NOT MOVE"
              types:new Backbone.Collection([
                name:"MOCK MOVE TYPE"
              ])
            ,
              name:"ALSO NOT MOVE"
              types:new Backbone.Collection([
                name:"MOCK MOVE TYPE"
              ])
            ]))
            a(()->
              rule.resolveAction(action, false)
            ,
              m.raisesAnything()
            )
          )
          test("asset located has move action but no type matching that specified in cation - throws", ()->
            asset.set("actions", new Backbone.Collection([
              name:"NOT MOVE"
              types:new Backbone.Collection([
                name:"MOCK MOVE TYPE"
              ])
            ,
              name:"move"
              types:new Backbone.Collection([
                name:"NOT MOCK MOVE TYPE"
              ,
                name:"ALSO NOT MOCK MOVE TYPE"
              ])
            ]))
            a(()->
              rule.resolveAction(action, false)
            ,
              m.raisesAnything()
            )
          )
          suite("Asset has move action with matching type", ()->
            suite("Turn specified in action", ()->
              turn = null
              setup(()->
                turn = new Backbone.Model(
                  name:"MOCK TURN TYPE"
                )
                action.set("turn", "MOCK TURN TYPE")
                asset.get("actions").at(0).get("types").at(0).set("turns", new Backbone.Collection([
                  turn
                ]))
              )
              test("move type has no turns - throws", ()->
                asset.get("actions").at(0).get("types").at(0).get("turns").reset()
                a(()->
                  rule.resolveAction(action, false)
                ,
                  m.raisesAnything()
                )
              )
            )
          )

        )
      )
    )
  )
)

