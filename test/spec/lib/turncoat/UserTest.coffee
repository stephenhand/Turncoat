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
          chai.assert.throw(()->
            challenger.issueChallenge(undefined, {})
          )
        )
        test("Game not set - throws",()->
          chai.assert.throw(()->
            challenger.issueChallenge("CHALLENGED_USER")
          )
        )
        test("Challenged user not assigned to a player in game - throws",()->
          chai.assert.throw(()->
            challenger.issueChallenge("NOT_CHALLENGED_USER")
          )
        )
        test("Valid input - calls transport sendChallenge with same user & game",()->
          challenger.issueChallenge("CHALLENGED_USER", game)
          JsMockito.verify(transport.sendChallenge)("CHALLENGED_USER",game)
        )
        test("Valid input - sets challenged player status to challenged",()->
          challenger.issueChallenge("CHALLENGED_USER", game)
          chai.assert.equal(game.get("players").at(0).get("user").get("status"),Constants.CHALLENGED_STATE)
        )
        test("Valid input - calls transport sendChallenge with game after status set",()->
          challenger.issueChallenge("CHALLENGED_USER", game)
          JsMockito.verify(transport.sendChallenge)("CHALLENGED_USER",new JsHamcrest.SimpleMatcher(
            describeTo:(d)->
              d.append("game")
            matches:(g)->
              g.get("players").at(0).get("user").get("status") is Constants.CHALLENGED_STATE
          ))
        )
        test("Valid input - saves game",()->
          challenger.issueChallenge("CHALLENGED_USER", game)
          JsMockito.verify(persister.saveGameState)("MOCK_USER",game)
        )
        test("Valid input - logs on game", ()->
          challenger.issueChallenge("CHALLENGED_USER", game)
          JsMockito.verify(game.logEvent)("MOCK_MOMENT_UTC",JsHamcrest.Matchers.string(),JsHamcrest.Matchers.string())
        )
      )
    )
  )


)

