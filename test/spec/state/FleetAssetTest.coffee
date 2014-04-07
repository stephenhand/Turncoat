require(["isolate", "isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("lib/turncoat/GameStateModel","state/FleetAsset", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      actual
    )
  )
  Isolate.mapAsFactory("lib/turncoat/StateRegistry","state/FleetAsset", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      registerType:JsMockito.mockFunction()
    )
  )
)

define(["isolate!state/FleetAsset", "jsMockito", "jsHamcrest", "chai"], (FleetAsset, jm, h, c)->
  mocks = window.mockLibrary["state/FleetAsset"]
  m = h.Matchers
  a = c.assert
  v = jm.Verifiers
  suite("FleetAsset", ()->
    suite("getPlayer", ()->
      fa = null
      class MockPlayer
      setup(()->
        mocks["lib/turncoat/StateRegistry"]["Player"]=MockPlayer
        fa = new FleetAsset()
      )
      test("Object whose type is registered as 'Player' is part of ownership chain - returns that object", ()->
        p = new MockPlayer()
        fa.getOwnershipChain = jm.mockFunction()
        jm.when(fa.getOwnershipChain)(m.anything()).then(()->
          [{},{},{}, p, {}, {}]
        )
        a.equal(fa.getOwningPlayer({}), p)
      )
      test("No such object is part of ownership chain - returns null", ()->
        fa.getOwnershipChain = jm.mockFunction()
        jm.when(fa.getOwnershipChain)(m.anything()).then(()->
          [{},{},{}, {}, {}, {}]
        )
        a.isNull(fa.getOwningPlayer({}))
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
        a.equal(fa.getOwningPlayer({}), p3)
      )
    )
  )


)

