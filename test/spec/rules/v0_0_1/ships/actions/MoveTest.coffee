require(["isolate", "isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("lib/turncoat/Action", "rules/v0_0_1/ships/actions/Move", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      Backbone.Model.extend({})
    )
  )
  Isolate.mapAsFactory("lib/turncoat/Event", "rules/v0_0_1/ships/actions/Move", (actual, modulePath, requestingModulePath)->
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
        suite("calculateManeuverRequired", ()->
          asset = null
          maneuver = null
          mockGSM = null
          setup(()->
            mockGSM = Backbone.Model.extend(
              initialize:()->
                @evaluate=jm.mockFunction()
                jm.when(@evaluate)(m.anything()).then((x)->@get(x))
            )
            asset = new Backbone.Model(
              id:"MOCK ASSET ID"
              position:new Backbone.Model(
                x:1
                y:1
                bearing:45
              )
            )
            asset.evaluate = jm.mockFunction()
          )
          test("Maneuver has no sequence - returns nothing", ()->
            a(rule.calculateManeuverRequired(asset, "MOCK MOVE TYPE", new Backbone.Model(
              name:"MOCK TURN TYPE"
              sequence:new Backbone.Collection([
                new mockGSM(
                  type:"move"
                  distance:1
                  direction:-45
                )
              ,
                new mockGSM(
                  type:"move"
                  distance:1
                )
              ,
                new mockGSM(
                  type:"move"
                  distance:1
                  direction:135
                )
              ]),
              cost:2
            ), 2, 2),m.nil())
          )
          test("Maneuver has empty sequence - returns nothing", ()->
            a(rule.calculateManeuverRequired(asset, "MOCK MOVE TYPE", new Backbone.Model(
              name:"MOCK TURN TYPE"
              sequence:new Backbone.Collection([]),
              cost:2
            ), 2, 2),m.nil())
          )
          suite("Maneuver is one rotation", ()->
            setup(()->
              maneuver=  new Backbone.Model(
                name:"MOCK TURN TYPE"
                sequence:new Backbone.Collection([
                  new mockGSM(
                    type:"rotate"
                    maxRotation:90
                    rotationAttribute:"MOCK_ROTATION"
                  )
                ]),
                cost:2
              )
            )
            test("Returns action object with asset id, move and maneuver types supplied", ()->
              ret = rule.calculateManeuverRequired(asset, "MOCK MOVE TYPE", maneuver, 2, 2)
              a(ret.action, m.instanceOf(mocks["lib/turncoat/Action"]))
              a(ret.action.attributes, m.allOf(
                  m.hasMember("rule","ships.actions.move")
                  m.hasMember("maneuver","MOCK TURN TYPE"),
                  m.hasMember("move","MOCK MOVE TYPE"),
                  m.hasMember("asset","MOCK ASSET ID")
                )
              )
            )
            test("Requested position is within maximum rotation - returns required rotation in attribute named as specified in rotationAttribute.", ()->
              ret = rule.calculateManeuverRequired(asset, "MOCK MOVE TYPE", maneuver, 2, 1)
              a(ret.action.get("MOCK_ROTATION"), 45)
              a(ret.shortfall, 0)
            )
            test("Requested position is within maximum rotation anticlockwise - returns required rotation as a negative", ()->
              ret = rule.calculateManeuverRequired(asset, "MOCK MOVE TYPE", maneuver, 1, 0)
              a(ret.action.get("MOCK_ROTATION"), -45)
              a(ret.shortfall, 0)
            )
            test("Requested position is outside maximum rotation - returns action with rotation at maximum rotation for maneuver and the shortfall in a 'shortfall' attribute", ()->
              ret = rule.calculateManeuverRequired(asset, "MOCK MOVE TYPE", maneuver, 1, 2)
              a(ret.action.get("MOCK_ROTATION"), 90)
              a(ret.shortfall, 45)
            )
            test("Requested position is outside maximum rotation anticlockwise - returns action with rotation at maximum negative rotation for maneuver and the shortfall in a 'shortfall' attribute", ()->
              ret = rule.calculateManeuverRequired(asset, "MOCK MOVE TYPE", maneuver, 0, 1)
              a(ret.action.get("MOCK_ROTATION"), -90)
              a(ret.shortfall, -45)
            )
          )
          suite("Turn has required prior move step but no post move step", ()->
            setup(()->
              asset.get("position").set("bearing", 90)
              maneuver=  new Backbone.Model(
                name:"MOCK TURN TYPE"
                sequence:new Backbone.Collection([
                  new mockGSM(
                    type:"move"
                    distance:1
                  )
                ,
                  new mockGSM(
                    type:"rotate"
                    maxRotation:90
                    rotationAttribute:"MOCK_ROTATION"
                  )
                ])
                cost:2
              )
            )
            test("Evaluates distance", ()->
              rule.calculateManeuverRequired(asset, "MOCK MOVE TYPE", maneuver, 3, 2)
              jm.verify(maneuver.get("sequence").at(0).evaluate)("distance")
            )
            test("Requested position is within maximum rotation after required move - returns action with asset id, move type, maneuver type and angle delta", ()->
              ret = rule.calculateManeuverRequired(asset, "MOCK MOVE TYPE", maneuver, 3, 2)
              a(ret.action.get("MOCK_ROTATION"), 45)
              a(ret.shortfall, 0)
            )
            test("Requested position is within maximum rotation anticlockwise - returns rotation required as attribute specified in rotationValueAttribute", ()->
              ret = rule.calculateManeuverRequired(asset, "MOCK MOVE TYPE", maneuver, 3, 0)
              a(ret.action.get("MOCK_ROTATION"), -45)
              a(ret.shortfall, 0)
            )
            test("Requested position is outside maximum rotation - returns action with maximum rotation and the shortfall in a 'shortfall' attribute", ()->
              ret = rule.calculateManeuverRequired(asset, "MOCK MOVE TYPE", maneuver, 1, 2)
              a(ret.action.get("MOCK_ROTATION"), 90)
              a(ret.shortfall, 45)
            )
            test("Requested position is outside maximum rotation anticlockwise - returns action with rotation at maximum negative rotation for maneuver and the shortfall in a 'shortfall' attribute", ()->
              ret = rule.calculateManeuverRequired(asset, "MOCK MOVE TYPE", maneuver, 1, 0)
              a(ret.action.get("MOCK_ROTATION"), -90)
              a(ret.shortfall, -45)
            )
            test("Starting move has direction specified - moves asset in direction specified in degrees then calculates rotation", ()->
              maneuver.get("sequence").at(0).set("direction",-90)
              ret = rule.calculateManeuverRequired(asset, "MOCK MOVE TYPE", maneuver, 2, 1)
              a(ret.action.get("MOCK_ROTATION"), 45)
              a(ret.shortfall, 0)
            )
            test("Maneuver has multiple move steps prior to rotation - executes them all to calculate required rotation", ()->
              maneuver.get("sequence").unshift(
                new mockGSM(
                  direction:90
                  type:"move"
                  distance:1
                )
              )
              maneuver.get("sequence").unshift(
                new mockGSM(
                  direction:180
                  type:"move"
                  distance:1
                )
              )
              ret = rule.calculateManeuverRequired(asset, "MOCK MOVE TYPE", maneuver, 2, 3)
              a(ret.action.get("MOCK_ROTATION"), 45)
              a(ret.shortfall, 0)
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

              events:new Backbone.Collection()
            )
            action.reset=jm.mockFunction()
            asset = new Backbone.Model(
              position:new Backbone.Model(
                bearing:0
                x:0
                y:0
              )
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
          test("Asset has no position - throws", ()->
            asset.unset("position")
            a(()->
              rule.resolveAction(action, false)
            ,
              m.raisesAnything()
            )
          )
          test("Asset has position missing x, y or bearing - throws", ()->
            asset.get("position").unset("bearing")
            a(()->
              rule.resolveAction(action, false)
            ,
              m.raisesAnything()
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
          test("asset located has move action but no type matching that specified in action - throws", ()->
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
            suite("Maneuver specified in action", ()->
              maneuver = null
              setup(()->
                maneuver = new Backbone.Model(
                  name:"MOCK TURN TYPE"
                  sequence:new Backbone.Collection([
                    type:"rotate"
                    maxRotation:"90"
                    rotationAttribute:"mockRotationValue"

                  ])
                  cost:2

                )
                action.set("maneuver", "MOCK TURN TYPE")
                action.set("mockRotationValue", -45)
                asset.get("actions").at(0).get("types").at(0).set("maneuvers", new Backbone.Collection([
                  maneuver
                ]))
                asset.set("position", new Backbone.Model(
                  x:3
                  y:5
                  bearing:180
                ))
              )
              test("move type has no maneuvers - throws", ()->
                asset.get("actions").at(0).get("types").at(0).get("maneuvers").reset()
                a(()->
                  rule.resolveAction(action, false)
                ,
                  m.raisesAnything()
                )
              )
              test("move type has maneuvers but none match the name specified in the action - throws", ()->
                asset.get("actions").at(0).get("types").at(0).get("maneuvers").reset([
                  new Backbone.Model(
                    name:"NOT MOCK TURN TYPE"
                    sequence:new Backbone.Collection()
                  ),
                  new Backbone.Model(
                    name:"ALSO NOT MOCK TURN TYPE"
                    sequence:new Backbone.Collection()
                  )
                ])
                a(()->
                  rule.resolveAction(action, false)
                ,
                  m.raisesAnything()
                )
              )
              test("move type has matching maneuver but no sequence - throws", ()->
                asset.get("actions").at(0).get("types").at(0).get("maneuvers").at(0).unset("sequence")
                a(()->
                  rule.resolveAction(action, false)
                ,
                  m.raisesAnything()
                )
              )
              test("maneuver sequence has at least one step - returns event with rule as ships.actions.move, name changePosition and a position model", ()->
                rule.resolveAction(action, false)
                event = action.get("events").at(0)
                a(event,  m.instanceOf(mocks["lib/turncoat/Event"]))
                a(event.get("rule"), "ships.actions.move")
                a(event.get("name"), "changePosition")
                a(event.get("position"), m.instanceOf(Backbone.Model))

              )
              test("maneuver sequence has single rotation step - adds single changePosition event that rotates asset on the spot", ()->
                rule.resolveAction(action, false)
                a(action.get("events").length, 1)
                event = action.get("events").at(0)
                a(event.get("position").get("x"), 3)
                a(event.get("position").get("y"), 5)
                a(event.get("position").get("bearing"), 135)

              )
              test("maneuver sequence has single rotation step - sets single waypoint marking start position", ()->
                rule.resolveAction(action, false)
                waypoints = action.get("events").at(0).get("waypoints")
                a(waypoints.length, 1)
                a(waypoints.at(0).get("x"), 3)
                a(waypoints.at(0).get("y"), 5)
                a(waypoints.at(0).get("bearing"), 180)

              )
              test("maneuver sequence has single rotation step but action doesn't have rotationAttribute specified in move - throws", ()->
                action.unset("mockRotationValue")
                a(()->
                  rule.resolveAction(action, false)
                ,
                  m.raisesAnything()
                )

              )
              test("maneuver sequence has single move without direction followed by single rotation step - adds single changePosition event that moves asset forwards by distance specified and rotates it.", ()->
                maneuver.get("sequence").reset([
                  type:"move"
                  distance:1
                ,
                  type:"rotate"
                  maxRotation:"90"
                  rotationAttribute:"mockRotationValue"

                ])
                maneuver.get("sequence").at(0).evaluate = (x)->@get(x)
                rule.resolveAction(action, false)
                a(action.get("events").length, 1)
                event = action.get("events").at(0)
                a(event.get("position").get("x"), 3)
                a(event.get("position").get("y"), 6)
                a(event.get("position").get("bearing"), 135)

              )
              test("moves in sequence are evaluated rather than got.", ()->
                maneuver.get("sequence").reset([
                  type:"move"
                  distance:1
                ,
                  type:"rotate"
                  maxRotation:"90"
                  rotationAttribute:"mockRotationValue"
                ])
                maneuver.get("sequence").at(0).evaluate = jm.mockFunction()
                jm.when(maneuver.get("sequence").at(0).evaluate)(m.anything()).then((x)->@get(x))
                rule.resolveAction(action, false)
                jm.verify(maneuver.get("sequence").at(0).evaluate)("distance")

              )
              test("maneuver sequence has single move with direction followed by single rotation step - adds single changePosition event that moves asset in direction specified by distance specified and rotates it.", ()->
                maneuver.get("sequence").reset([
                  type:"move"
                  distance:1
                  direction:180
                ,
                  type:"rotate"
                  maxRotation:"90"
                  rotationAttribute:"mockRotationValue"

                ])
                maneuver.get("sequence").at(0).evaluate = (x)->@get(x)
                rule.resolveAction(action, false)
                a(action.get("events").length, 1)
                event = action.get("events").at(0)
                a(event.get("position").get("x"), 3)
                a(event.get("position").get("y"), 4)
                a(event.get("position").get("bearing"), 135)

              )
              test("maneuver sequence has single move followed by single rotation step - sets two waypoints with bearing on start.", ()->
                maneuver.get("sequence").reset([
                  type:"move"
                  distance:1
                  direction:180
                ,
                  type:"rotate"
                  maxRotation:"90"
                  rotationAttribute:"mockRotationValue"

                ])
                maneuver.get("sequence").at(0).evaluate = (x)->@get(x)
                rule.resolveAction(action, false)
                waypoints = action.get("events").at(0).get("waypoints")
                a(waypoints.length, 2)
                a(waypoints.at(0).get("x"), 3)
                a(waypoints.at(0).get("y"), 5)
                a(waypoints.at(0).get("bearing"), 180)
                a(waypoints.at(1).get("x"), 3)
                a(waypoints.at(1).get("y"), 4)
                a(waypoints.at(1).get("bearing"), m.nil())
              )
              test("maneuver sequence has several moves and rotations - applies them all to final new position", ()->
                action.set("mockRotationValue2", 45)
                maneuver.get("sequence").reset([
                  type:"move"
                  distance:3
                  direction:-90
                ,
                  type:"rotate"
                  maxRotation:90
                  rotationAttribute:"mockRotationValue"
                ,
                  type:"move"
                  distance:2
                  direction:-45
                ,
                  type:"rotate"
                  maxRotation:"90"
                  rotationAttribute:"mockRotationValue2"
                ,
                  type:"move"
                  distance:4
                ])
                maneuver.get("sequence").at(0).evaluate = (x)->@get(x)
                maneuver.get("sequence").at(2).evaluate = (x)->@get(x)
                maneuver.get("sequence").at(4).evaluate = (x)->@get(x)
                rule.resolveAction(action, false)
                a(action.get("events").length, 1)
                event = action.get("events").at(0)
                a(event.get("position").get("x"), 8)
                a(event.get("position").get("y"), 9)
                a(event.get("position").get("bearing"), 180)

              )
              test("maneuver sequence has several moves and rotations - sets correct waypoints on event, only specifying bearing at start", ()->
                action.set("mockRotationValue2", 45)
                maneuver.get("sequence").reset([
                  type:"move"
                  distance:3
                  direction:-90
                ,
                  type:"rotate"
                  maxRotation:90
                  rotationAttribute:"mockRotationValue"
                ,
                  type:"move"
                  distance:2
                  direction:-45
                ,
                  type:"rotate"
                  maxRotation:90
                  rotationAttribute:"mockRotationValue2"
                ,
                  type:"move"
                  distance:4
                ])
                maneuver.get("sequence").at(0).evaluate = (x)->@get(x)
                maneuver.get("sequence").at(2).evaluate = (x)->@get(x)
                maneuver.get("sequence").at(4).evaluate = (x)->@get(x)
                rule.resolveAction(action, false)
                waypoints = action.get("events").at(0).get("waypoints")
                a(waypoints.length, 4)
                a(waypoints.at(0).get("x"), 3)
                a(waypoints.at(0).get("y"), 5)
                a(waypoints.at(0).get("bearing"), 180)
                a(waypoints.at(1).get("x"), 6)
                a(waypoints.at(1).get("y"), 5)
                a(waypoints.at(1).get("bearing"), m.nil())
                a(waypoints.at(2).get("x"), 8)
                a(waypoints.at(2).get("y"), 5)
                a(waypoints.at(2).get("bearing"), m.nil())
                a(waypoints.at(3).get("x"), 8)
                a(waypoints.at(3).get("y"), 9)
                a(waypoints.at(3).get("bearing"), m.nil())
              )
            )
          )

        )
      )
    )
  )
)

