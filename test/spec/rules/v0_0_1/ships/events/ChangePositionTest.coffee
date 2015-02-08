
mockFleetAsset = {}

require(["isolate", "isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("state/FleetAsset","rules/v0_0_1/ships/events/ChangePosition", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      mockFleetAsset
    )
  )
)

define(["isolate!rules/v0_0_1/ships/events/ChangePosition", "matchers", "operators", "assertThat", "jsMockito",
        "verifiers", "backbone" ], (ChangePosition, m, o, a, jm, v, Backbone)->
  mocks = window.mockLibrary["rules/v0_0_1/ships/events/ChangePosition"]
  suite("ChangePosition", ()->
    suite("getRules", ()->
      game = null
      rules = null
      asset = null
      setup(()->
        game = {}
        asset = new Backbone.Model(
          position:new Backbone.Model(
            x:5
            y:10
            bearing:25
          )
        )
        mockFleetAsset.findByID = jm.mockFunction()
        jm.when(mockFleetAsset.findByID)(game, "AN ID").then(()->
          asset
        )
        rules = ChangePosition.getRules(game)
      )
      suite("apply", ()->
        event = null
        test("No event supplied - throws", ()->
          a(
            ()->
              rules.apply()
          ,
            m.raisesAnything()
          )
        )
        test("Attempts to find asset with ID supplied in event using FleetAsset.findByID", ()->
          event = new Backbone.Model(
            asset:"AN ID"
            vector:new Backbone.Model(
              x:23
              y:16
              rotation:-45
            )
          )
          rules.apply(event)
          jm.verify(mockFleetAsset.findByID)(game, "AN ID")
        )
        test("Event supplied with asset ID that findByID cannot find - throws", ()->
          event = new Backbone.Model(
            asset:"NOT AN ID"
            vector:new Backbone.Model(
              x:23
              y:16
              rotation:-45
            )
          )
          a(
            ()->
              rules.apply(event)
          ,
            m.raisesAnything()
          )
        )
        suite("Event supplied with asset ID which finds asset", ()->
          setup(()->
            event = new Backbone.Model(
              asset:"AN ID"
            )
          )
          test("No vector supplied - throws", ()->
            a(
              ()->
                rules.apply(event)
            ,
              m.raisesAnything()
            )
          )
          suite("Vector model supplied", ()->
            setup(()->
              event = new Backbone.Model(
                asset:"AN ID"
                vector:new Backbone.Model(
                  x:23
                  y:-16
                  rotation:-45
                )
              )
            )
            test("x and y vectors supplied - adjusts asset position x and y values by vector values", ()->
              rules.apply(event)
              a(asset.get("position").get("x"), 28)
              a(asset.get("position").get("y"), -6)
            )
            test("x vector omitted - assumes zero", ()->
              event.get("vector").unset("x")
              rules.apply(event)
              a(asset.get("position").get("x"), 5)
              a(asset.get("position").get("y"), -6)
            )
            test("y vector omitted - assumes zero", ()->
              event.get("vector").unset("y")
              rules.apply(event)
              a(asset.get("position").get("x"), 28)
              a(asset.get("position").get("y"), 10)
            )
            test("Rotation supplied - rotates bearing of asset position by value specified", ()->
              rules.apply(event)
              a(asset.get("position").get("bearing"), 340)
            )
            test("Rotation not supplied - assumes zero", ()->
              event.get("vector").unset("rotation")
              rules.apply(event)
              a(asset.get("position").get("bearing"), 25)
            )
          )
        )
      )
    )
  )
)

