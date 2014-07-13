require(["isolate", "isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("rules/RuleBook_v0_0_1", "state/ManOWarGameState", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      actual
    )
  )
)

define(["isolate!state/ManOWarGameState", "matchers", "operators", "assertThat", "jsMockito", "verifiers"], (ManOWarGameState, m, o, a, jm, v)->
  mocks = window.mockLibrary["state/ManOWarGameState"]
  suite("ManOWarGameState", ()->
    suite("getCurrentControllingPlayer", ()->
      mowgs = null
      setup(()->
        mowgs = new ManOWarGameState()
        mowgs.set("players",new Backbone.Collection([
          id:"PLAYER 1"
        ,
          id:"PLAYER 2"
        ,
          id:"PLAYER 3"
        ,
          id:"PLAYER 4"
        ]))
        mowgs.getLastMove = jm.mockFunction()
      )
      suite("Has last move", ()->
        mv = null
        setup(()->
          mv =
            getEndControllingPlayerId:jm.mockFunction()
          jm.when(mowgs.getLastMove)().then(()->
            mv
          )
        )
        test("Last move returns a player id - returns player with id", ()->
          jm.when(mv.getEndControllingPlayerId)().then(()->
            "PLAYER 2"
          )
          a(mowgs.getCurrentControllingPlayer(), mowgs.get("players").at(1))
        )
        test("Last move returns a missing id - throws", ()->
          jm.when(mv.getEndControllingPlayerId)().then(()->
            "NOT A PLAYER"
          )
          a(
            ()->mowgs.getCurrentControllingPlayer()
          ,m.raisesAnything())
        )
        test("Last move returns undefined - uses first player in list", ()->
          jm.when(mv.getEndControllingPlayerId)().then(()->)
          a(mowgs.getCurrentControllingPlayer(), mowgs.get("players").first())
        )
      )
      test("Has no last move - returns first player in list", ()->
        jm.when(mowgs.getLastMove)().then(()->)
        a(mowgs.getCurrentControllingPlayer(), mowgs.get("players").first())
      )
      test("Has no players - throws", ()->
        mowgs.unset("players")
        jm.when(mowgs.getLastMove)().then(()->)
        a(
          ()->mowgs.getCurrentControllingPlayer()
        ,m.raisesAnything())
      )
    )

    suite("getCurrentControllingPlayer", ()->
      suite("Has 'users' Backbone Collection", ()->
        mowgs = null
        setup(()->
          mowgs = new ManOWarGameState(
            users:new Backbone.Collection([
              id:"USER 1"
              playerId:"PLAYER 1"
            ,
              id:"USER 2"
              playerId:"PLAYER 2"
            ,
              id:"USER 3"
              playerId:"NOT PLAYER 3"
            ,
              id:"USER 4"
            ])
          )
          mowgs.set("players",new Backbone.Collection([
            id:"PLAYER 1"
          ,
            id:"PLAYER 2"
          ,
            id:"PLAYER 3"
          ,
            id:"PLAYER 4"
          ]))
          mowgs.getCurrentControllingPlayer = jm.mockFunction()
          jm.when(mowgs.getCurrentControllingPlayer)().then(()->mowgs.get("players").at(0))
        )
        test("Calls getCurrentControllingPlayer", ()->
          mowgs.getCurrentControllingUser()
          jm.verify(mowgs.getCurrentControllingPlayer)()
        )
        test("User exists with playerId of player - returns user", ()->
          jm.when(mowgs.getCurrentControllingPlayer)().then(()->mowgs.get("players").at(1))
          a(mowgs.getCurrentControllingUser(),mowgs.get("users").at(1))
        )
        test("User does not exist with playerId of player - throws", ()->
          jm.when(mowgs.getCurrentControllingPlayer)().then(()->mowgs.get("players").at(2))
          a(
            ()->mowgs.getCurrentControllingUser()
          ,m.raisesAnything())
        )
      )
      test("Has invalid 'users' collection - throws", ()->
        mowgs = new ManOWarGameState(
          users:{}
        )
        mowgs.set("players",new Backbone.Collection([
          id:"PLAYER 1"
          userId:"USER 1"
        ]))
        mowgs.getCurrentControllingPlayer = jm.mockFunction()
        jm.when(mowgs.getCurrentControllingPlayer)().then(()->mowgs.get("players").at(0))
        a(
          ()->mowgs.getCurrentControllingUser()
        ,m.raisesAnything())
      )
      test("Has no 'users' collection - throws", ()->
        mowgs = new ManOWarGameState()
        mowgs.set("players",new Backbone.Collection([
          id:"PLAYER 1"
          userId:"USER 1"
        ]))
        mowgs.getCurrentControllingPlayer = jm.mockFunction()
        jm.when(mowgs.getCurrentControllingPlayer)().then(()->mowgs.get("players").at(0))
        a(
          ()->mowgs.getCurrentControllingUser()
        ,m.raisesAnything())
      )
    )
  )


)

