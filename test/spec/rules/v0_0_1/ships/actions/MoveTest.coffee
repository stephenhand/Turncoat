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

    suite("getRule", ()->
      test("Game supplied - returns object", ()->
        a(Move.getRule({}), m.object())
      )
      test("Game not supplied - throws", ()->
        a(()->
          Move.getRule()
        ,
          m.raisesAnything())
      )
      suite("Rules object.", ()->
        rule = null
        game = null
        setup(()->
          game = {}
          rule = Move.getRule(game)
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
        )
      )
    )
  )
)

