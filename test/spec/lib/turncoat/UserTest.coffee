require(["isolate","isolateHelper"], (Isolate, Helper)->

  Isolate.mapAsFactory("lib/turncoat/Factory", "lib/turncoat/User", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      {}
    )
  )
  Isolate.mapAsFactory("moment", "lib/turncoat/User", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      utc:()->
        "MOCK_MOMENT_UTC"
    )
  )
)


define(["isolate!lib/turncoat/User", "lib/turncoat/Constants"], (User, Constants)->
  m = JsHamcrest.Matchers
  a = chai.assert
  jm = JsMockito
  v = JsMockito.Verifiers
  mocks = window.mockLibrary["lib/turncoat/User"]

  suite("User", ()->

    transport = null
    persister = null
    setup(()->
      persister =
        saveGameState:JsMockito.mockFunction()
      transport =
        sendChallenge: JsMockito.mockFunction()
      mocks["lib/turncoat/Factory"].buildTransport=JsMockito.mockFunction()
      JsMockito.when(mocks["lib/turncoat/Factory"].buildTransport)(JsHamcrest.Matchers.anything()).then((opts)->
        transport
      )
      mocks["lib/turncoat/Factory"].buildPersister=JsMockito.mockFunction()
      JsMockito.when(mocks["lib/turncoat/Factory"].buildPersister)().then(()->
        persister
      )
    )
    suite("constructor", ()->

      test("Builds transport with user id.", ()->
        new User(
          id:"AN ID"
        )
        jm.verify(mocks["lib/turncoat/Factory"].buildTransport)(m.hasMember("userId", "AN ID"))
      )
      test("Builds persister.", ()->
        new User(
          id:"AN ID"
        )
        jm.verify(mocks["lib/turncoat/Factory"].buildPersister)()
      )
    )
    suite("issueChallenge", ()->
      game = {}
      challenger = null
      setup(()->
        game = new Backbone.Model(
          players:new Backbone.Collection([
            user:new Backbone.Model(
              id:"CHALLENGED_USER"
            )

          ])
        )
        game.logEvent=JsMockito.mockFunction()
        challenger = new User(id:"MOCK_USER")
      )
      test("Challenged user not set - throws",()->
        a.throw(()->
          challenger.issueChallenge(undefined, {})
        )
      )
      test("Game not set - throws",()->
        a.throw(()->
          challenger.issueChallenge("CHALLENGED_USER")
        )
      )
      test("Challenged user not assigned to a player in game - throws",()->
        a.throw(()->
          challenger.issueChallenge("NOT_CHALLENGED_USER")
        )
      )
      test("Valid input - calls transport sendChallenge with same user & game",()->
        challenger.issueChallenge("CHALLENGED_USER", game)
        jm.verify(transport.sendChallenge)("CHALLENGED_USER",game)
      )
      test("Valid input - sets challenged player status to challenged",()->
        challenger.issueChallenge("CHALLENGED_USER", game)
        a.equal(game.get("players").at(0).get("user").get("status"),Constants.CHALLENGED_STATE)
      )
      test("Valid input - calls transport sendChallenge with game after status set",()->
        challenger.issueChallenge("CHALLENGED_USER", game)
        jm.verify(transport.sendChallenge)("CHALLENGED_USER",new JsHamcrest.SimpleMatcher(
          describeTo:(d)->
            d.append("game")
          matches:(g)->
            g.get("players").at(0).get("user").get("status") is Constants.CHALLENGED_STATE
        ))
      )
      test("Valid input - saves game",()->
        challenger.issueChallenge("CHALLENGED_USER", game)
        jm.verify(persister.saveGameState)("MOCK_USER",game)
      )
      test("Valid input - logs event with challenged user and challenging user", ()->
        challenger.issueChallenge("CHALLENGED_USER", game)
        jm.verify(game.logEvent)("MOCK_MOMENT_UTC",m.allOf(m.containsString("MOCK_USER"),m.containsString("CHALLENGED_USER")),m.string())
      )
    )
    suite("acceptChallenge", ()->
      game = {}
      challenger = null
      event = {}
      setup(()->
        transport.broadcastEvent = jm.mockFunction()
        game = new Backbone.Model(
          players:new Backbone.Collection([
            user:new Backbone.Model(
              id:"MOCK_USER"
            )
          ,
            user:new Backbone.Model(
              id:"OTHER_CHALLENGED_USER"
            )
          ,
            user:new Backbone.Model(
              id:"OTHER_OTHER_CHALLENGED_USER"
            )

          ])
        )
        game.logEvent=JsMockito.mockFunction()
        jm.when(game.logEvent)(m.anything(),m.anything(),m.anything()).then((a,b,c)->
          event
        )
        challenger = new User(id:"MOCK_USER")
      )
      test("Game not set - throws",()->
        a.throw(()->
          challenger.acceptChallenge()
        )
      )
      test("User not assigned to a player in game - throws",()->
        a.throw(()->
          challenger.acceptChallenge(new Backbone.Model(
            players:new Backbone.Collection([
              user:new Backbone.Model(
                id:"NOT CHALLENGED_USER"
              )
            ])
          ))
        )
      )

      test("Valid input, user currently has no status - changes user status to 'READY'",()->
        challenger.acceptChallenge(game)
        a.equal(game.get("players").at(0).get("user").get("status"), Constants.READY_STATE)
      )
      suite("User currently has other status", ()->
        setup(()->
          game.get("players").at(0).get("user").set("status", "SOMETHING ELSE")
        )
        test("Changes user status to 'READY'",()->
          challenger.acceptChallenge(game)
          a.equal(game.get("players").at(0).get("user").get("status"), Constants.READY_STATE)
        )
        test("Logs event with current time and 'ready' status and user id in data.",()->
          challenger.acceptChallenge(game)
          jm.verify(game.logEvent)("MOCK_MOMENT_UTC", m.string(), m.hasMember("attributes", m.allOf(m.hasMember("userid","MOCK_USER"),m.hasMember("status", Constants.READY_STATE))))
        )
        test("Broadcasts logged event via transport", ()->
          challenger.acceptChallenge(game)
          jm.verify(transport.broadcastEvent)(m.anything(), event)
        )
        test("Broadcasts with all users except the current one as recipients", ()->
          challenger.acceptChallenge(game)
          jm.verify(transport.broadcastEvent)(m.hasItems("OTHER_CHALLENGED_USER","OTHER_OTHER_CHALLENGED_USER"), m.anything())
        )
        test("Current user is only user - doesn't broadcast.", ()->
          g = new Backbone.Model(
            players:new Backbone.Collection([
              user:new Backbone.Model(
                id:"MOCK_USER"
              )
            ])
          )
          g.logEvent=()->
          challenger.acceptChallenge(g)
          jm.verify(transport.broadcastEvent, v.never())(m.anything(), m.anything())
        )
      )
      suite("User currently has 'ready' status", ()->
        setup(()->
          game.get("players").at(0).get("user").set("status", Constants.READY_STATE)
        )
        test("Leave user status to 'READY'",()->
          challenger.acceptChallenge(game)
          a.equal(game.get("players").at(0).get("user").get("status"), Constants.READY_STATE)
        )
      )

    )

  )


)

