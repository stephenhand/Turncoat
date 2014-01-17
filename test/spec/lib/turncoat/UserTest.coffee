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
        on:jm.mockFunction()
        off:jm.mockFunction()
        saveGameState:jm.mockFunction()
        loadGameTemplateList:jm.mockFunction()
        loadGameTypes:jm.mockFunction()
        loadGameTemplate:jm.mockFunction()
        loadGameList:jm.mockFunction()
        loadGameState:jm.mockFunction()
      transport =
        sendChallenge: jm.mockFunction()
        startListening:jm.mockFunction()
        stopListening:jm.mockFunction()
        on:jm.mockFunction()
        off:jm.mockFunction()
      mocks["lib/turncoat/Factory"].buildTransport=jm.mockFunction()
      jm.when(mocks["lib/turncoat/Factory"].buildTransport)(m.anything()).then((opts)->
        transport
      )
      mocks["lib/turncoat/Factory"].buildPersister=jm.mockFunction()
      jm.when(mocks["lib/turncoat/Factory"].buildPersister)().then(()->
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
    suite("activate", ()->
      user = null
      setup(()->
        user = new User(id:"MOCK_USER")
      )
      test("Calls transport's 'startListening'", ()->
        user.activate()
        jm.verify(transport.startListening)()
      )
      test("Sets game templates using User ID and null Type", ()->
        list = {}
        jm.when(persister.loadGameTemplateList)(m.anything(), m.anything()).then(
          (a, b)->
            list
        )
        user.activate()
        jm.verify(persister.loadGameTemplateList)(null, "MOCK_USER")
        chai.assert.equal(user.get("gameTemplates"), list)
      )
      test("Sets Games", ()->
        list = {}
        jm.when(persister.loadGameList)(m.anything()).then(
          (a)->
            list
        )
        user.activate()
        jm.verify(persister.loadGameList)("MOCK_USER")
        chai.assert.equal(user.get("games"), list)
      )
      test("Listens to transport's ''challengeReceived' handler", ()->
        user.listenTo = jm.mockFunction()
        user.activate()
        jm.verify(user.listenTo)(transport, "challengeReceived", m.func())
      )
      test("Applies persister GameListUpdated Handler", ()->
        user.activate()
        user.get("games").set=jm.mockFunction()
        jm.verify(persister.on)("gameListUpdated",m.anything(),user)
      )
      test("Multiple calls calls 'startListening' once.", ()->
        user.activate()
        user.activate()
        user.activate()
        user.activate()
        jm.verify(transport.startListening, v.once())()
      )
      suite("challengeReceived handler", ()->
        test("Saves challenge to persister", ()->
          user.listenTo = jm.mockFunction()
          user.activate()
          jm.verify(user.listenTo)(transport, "challengeReceived", new JsHamcrest.SimpleMatcher(
            describeTo:(d)->
              d.append("challengeReceived handler")
            matches:(handler)->
              try
                game =
                  logEvent:JsMockito.mockFunction()
                handler(game)
                jm.verify(persister.saveGameState)("MOCK_USER",game)
                true
              catch e
                false

          ))
        )
      )
      suite("gameListUpdated Handler", ()->
        setup(()->
          jm.when(persister.loadGameList)("MOCK_USER").then(()->
            new Backbone.Collection()
          )
        )
        test("Current User - Updates Games", ()->
          user.activate()
          jm.verify(persister.on)("gameListUpdated",
            new JsHamcrest.SimpleMatcher(
              matches:(input)->
                user.get("games").set=JsMockito.mockFunction()
                newVal=
                  userId:"MOCK_USER"
                  list:new Backbone.Collection([])
                input.call(user, newVal)
                try
                  jm.verify(user.get("games").set)(newVal.list.models)
                  true
                catch e
                  false
            )
          ,user)
        )
        test("Other User - Does nothing", ()->
          user.activate()
          JsMockito.verify(persister.on)("gameListUpdated",
            new JsHamcrest.SimpleMatcher(
              matches:(input)->
                user.get("games").set=jm.mockFunction()
                newVal=
                  userId:"OTHER_USER"
                  list:new Backbone.Collection([])
                input.call(user, newVal)
                try
                  jm.verify(user.get("games").set, v.never())(m.anything())
                  true
                catch e
                  false
            )
          ,user)
        )
      )
      suite("deactivate", ()->
        test("Calls transport's 'stopListening'", ()->
          user.activate()
          user.deactivate()
          jm.verify(transport.stopListening)()
        )
        test("Removes persister's GameListUpdated Handler", ()->
          user.activate()
          user.deactivate()
          JsMockito.verify(persister.off)("gameListUpdated",null,user)
        )
        test("Stops listening to transport", ()->
          user.listenTo = jm.mockFunction()
          user.stopListening = jm.mockFunction()
          user.activate()
          user.deactivate()
          jm.verify(user.stopListening)(transport)
        )
        test("Multiple calls calls 'stopListening' once.", ()->
          user.activate()
          user.deactivate()
          user.deactivate()
          user.deactivate()
          user.deactivate()
          user.deactivate()
          user.deactivate()
          jm.verify(transport.stopListening)()
        )
        test("Called before activate - does nothing.", ()->
          user.deactivate()
          jm.verify(transport.stopListening, v.never())()
        )
        test("Multiple calls 'stopListening' once.", ()->
          user.activate()
          user.deactivate()
          user.deactivate()
          user.deactivate()
          user.deactivate()
          user.deactivate()
          user.deactivate()
          jm.verify(transport.stopListening)()
        )
      )
      test("Activate / Deactivate toggle", ()->
        user.activate()
        user.deactivate()
        user.deactivate()
        user.activate()
        user.activate()
        user.activate()
        user.deactivate()
        user.deactivate()
        user.activate()
        user.deactivate()
        user.activate()
        user.deactivate()
        jm.verify(transport.startListening, v.times(4))()
        jm.verify(transport.stopListening, v.times(4))()

      )
    )

  )


)

