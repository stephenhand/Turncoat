require(["isolate", "isolateHelper"], (Isolate, Helper)->

)

define(["isolate!rules/ManOWarMove", "jsMockito", "jsHamcrest", "chai"], (ManOWarMove, jm, h, c)->
  mocks = window.mockLibrary["rules/MOWMove"]
  m = h.Matchers
  a = c.assert
  v = jm.Verifiers
  suite("ManOWarMove", ()->
    suite("getEndControllingPlayerId", ()->
      test("Move has action with playerId - returns playerId", ()->
        mm = new ManOWarMove(actions:new Backbone.Collection([
          playerId:"MOCK PLAYER"
        ]))
        a.equal(mm.getEndControllingPlayerId(), "MOCK PLAYER")
      )
      test("Move has several actiona with playerIda - returns playerId of last action", ()->
        mm = new ManOWarMove(actions:new Backbone.Collection([
          playerId:"MOCK PLAYER1"
        ,
          playerId:"MOCK PLAYER2"
        ,
          playerId:"MOCK PLAYER3"
        ,
          playerId:"MOCK PLAYER4"
        ]))
        a.equal(mm.getEndControllingPlayerId(), "MOCK PLAYER4")
      )
      test("Move has last action without playerId - returns nil", ()->
        mm = new ManOWarMove(actions:new Backbone.Collection([
          playerId:"MOCK PLAYER1"
        ,
          playerId:"MOCK PLAYER2"
        ,
          playerId:"MOCK PLAYER3"
        ,
          {}
        ]))
        a.isUndefined(mm.getEndControllingPlayerId())
      )
      test("Move has empty actions collection - throws", ()->
        mm = new ManOWarMove(actions:new Backbone.Collection([]))
        a.throw(()->mm.getEndControllingPlayerId())
      )
      test("Move has invalid actions collection - throws", ()->
        mm = new ManOWarMove(actions:[playerId:"SOMETHING"])
        a.throw(()->mm.getEndControllingPlayerId())
      )
      test("Move has no actions collection - throws", ()->
        mm = new ManOWarMove()
        mm.unset("actions")
        a.throw(()->mm.getEndControllingPlayerId())
      )
    )
  )


)

