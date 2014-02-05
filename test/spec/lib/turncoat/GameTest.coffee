GSMConstructor = null

require(["isolate","isolateHelper"], (Isolate, Helper)->

  Isolate.mapAsFactory("lib/turncoat/GameStateModel","lib/turncoat/Game", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      GSMConstructor = actual
      GSMConstructor
    )
  )

  Isolate.mapAsFactory("lib/turncoat/Factory", "lib/turncoat/Game", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      {}
    )
  )
)
define(["isolate!lib/turncoat/Game", "lib/turncoat/Constants"], (Game, Constants)->
  m = JsHamcrest.Matchers
  a = chai.assert
  jm = JsMockito
  v = JsMockito.Verifiers
  mocks = window.mockLibrary["lib/turncoat/Game"]

  suite("Game", ()->
    transport = null
    persister = null
    setup(()->
      transport =
        sendChallenge: jm.mockFunction()
        broadcastGameEvent: jm.mockFunction()
        startListening:jm.mockFunction()
        stopListening:jm.mockFunction()
        on:jm.mockFunction()
        off:jm.mockFunction()
      persister =
        saveGameState:jm.mockFunction()
      mocks["lib/turncoat/Factory"].buildTransport = jm.mockFunction()
      jm.when(mocks["lib/turncoat/Factory"].buildTransport)(m.anything()).then((opts)->
        transport
      )
      mocks["lib/turncoat/Factory"].buildPersister = jm.mockFunction()
      jm.when(mocks["lib/turncoat/Factory"].buildPersister)().then((opts)->
        persister
      )
    )
    suite("initialize", ()->
      test("Calls super initialize with same parameters", ()->
        origGSMInit = GSMConstructor.prototype.initialize
        GSMConstructor.prototype.initialize = jm.mockFunction()
        opt ={}
        att = {}
        g = new Game(att, opt)
        jm.verify(GSMConstructor.prototype.initialize)(att, opt)
        GSMConstructor.prototype.initialize = origGSMInit
      )
      test("Builds transport using game Id", ()->
        new Game(
          id:"A GAME ID"
        ,{})
        jm.verify(mocks["lib/turncoat/Factory"].buildTransport)(
          m.allOf(
            m.hasMember("gameId","A GAME ID")
          )
        )
      )
      test("Builds persister", ()->
        new Game(
          id:"A GAME ID"
        ,{})
        jm.verify(mocks["lib/turncoat/Factory"].buildPersister)()
      )
    )

    suite("activate", ()->
      game = null
      setup(()->
        game = new Game(
          id:"A GAME ID"
        ,
          userId:"A USER ID"
        )
      )
      test("No parameter - throws", ()->
        a.throw(()->
          game.activate()
        )
      )
      test("Sets transport's userId to  supplied parameter", ()->
        game.activate("A USER ID")
        a.equal(transport.userId, "A USER ID")
      )
      test("Calls transport's 'startListening'", ()->
        game.activate("A USER ID")
        jm.verify(transport.startListening)()
      )
      test("Listens to transport's 'eventReceived' handler", ()->
        game.listenTo = jm.mockFunction()
        game.activate("A USER ID")
        jm.verify(game.listenTo)(transport, "eventReceived", m.func())
      )
      test("Multiple calls calls 'startListening' once.", ()->
        game.activate("A USER ID")
        game.activate("A USER ID")
        game.activate("A USER ID")
        game.activate("A USER ID")
        jm.verify(transport.startListening, v.once())()
      )
      test("Multiple calls calls 'startListening' once even if Id changes.", ()->
        game.activate("A USER ID")
        game.activate("ANOTHER USER ID")
        jm.verify(transport.startListening, v.once())()
        a.equal(transport.userId, "A USER ID")
      )
      suite("eventReceived handler", ()->
        handler = null
        event = null
        setup(()->
          game.listenTo = jm.mockFunction()
          jm.when(game.listenTo)(transport, "eventReceived", m.func()).then((t, e, f)=>
            handler = f
          )
          game.activate("A USER ID")
          game.logEvent = jm.mockFunction()
          event = new Backbone.Model()
        )
        test("Logs event", ()->
          handler.call(game,event)
          jm.verify(game.logEvent)(event)
        )
        test("Event not Backbone Model - throws", ()->
          a.throw(()->handler({}))
        )
        suite("Event is USERSTATUSCHANGED", ()->
          setup(()->
            game.set("users", new Backbone.Collection([
              id:"MOCK USER"
            ,
              id:"NOT MOCK USER"
            ]))
            event.set("name", Constants.LogEvents.USERSTATUSCHANGED)
            event.set("data", new Backbone.Model(
              userId:"MOCK USER"
              status:"MOCK STATUS"
            ))
          )
          test("Data missing - does nothing", ()->
            event.unset("data")
            handler.call(game,event)
            a.isUndefined(game.get("users").get("MOCK USER").get("status"))
            a.isUndefined(game.get("users").get("NOT MOCK USER").get("status"))
          )
          test("User Id missing - does nothing", ()->
            event.get("data").unset("userId")
            handler.call(game,event)
            a.isUndefined(game.get("users").get("MOCK USER").get("status"))
            a.isUndefined(game.get("users").get("NOT MOCK USER").get("status"))
          )
          test("Status missing - does nothing", ()->
            game.get("users").get("MOCK USER").set("status", "EXISTING STATUS")
            event.get("data").unset("status")
            handler.call(game,event)
            a.equal(game.get("users").get("MOCK USER").get("status"), "EXISTING STATUS")
            a.isUndefined(game.get("users").get("NOT MOCK USER").get("status"))
          )
          test("User Id is not in game user list - does nothing", ()->
            event.get("data").set("userId", "MISSING USER")
            handler.call(game,event)
            a.isUndefined(game.get("users").get("MOCK USER").get("status"))
            a.isUndefined(game.get("users").get("NOT MOCK USER").get("status"))
          )
          test("Game has no user collection - does nothing", ()->
            game.unset("users")
            handler.call(game,event)
            a.isUndefined(game.get("users"))
          )
          test("Specified user exists and status set - sets status", ()->
            handler.call(game,event)
            a.equal(game.get("users").get("MOCK USER").get("status"),"MOCK STATUS")
          )
          test("Specified user exists and status set - save's game state via persister using transport's user id", ()->
            handler.call(game,event)
            jm.verify(persister.saveGameState)("A USER ID", game)
          )
        )
      )
      suite("deactivate", ()->
        test("Calls transport's 'stopListening'", ()->
          game.activate("A USER ID")
          game.deactivate()
          jm.verify(transport.stopListening)()
        )
        test("Stops listening to transport", ()->
          game.listenTo = jm.mockFunction()
          game.stopListening = jm.mockFunction()
          game.activate("A USER ID")
          game.deactivate()
          jm.verify(game.stopListening)(transport)
        )
        test("Multiple calls calls 'stopListening' once.", ()->
          game.listenTo = jm.mockFunction()
          game.stopListening = jm.mockFunction()
          game.activate("A USER ID")
          game.deactivate()
          game.deactivate()
          game.deactivate()
          game.deactivate()
          game.deactivate()
          game.deactivate()
          jm.verify(game.stopListening)()
        )
        test("Called before activate - does nothing.", ()->
          game.deactivate()
          jm.verify(transport.stopListening, v.never())()
        )
        test("Multiple calls 'stopListening' once.", ()->
          game.activate("A USER ID")
          game.deactivate()
          game.deactivate()
          game.deactivate()
          game.deactivate()
          game.deactivate()
          game.deactivate()
          jm.verify(transport.stopListening)()
        )
      )
      test("Activate / Deactivate toggle", ()->
        game.activate("A USER ID")
        game.deactivate()
        game.deactivate()
        game.activate("A USER ID")
        game.activate("A USER ID")
        game.activate("A USER ID")
        game.deactivate()
        game.deactivate()
        game.activate("A USER ID")
        game.deactivate()
        game.activate("A USER ID")
        game.deactivate()
        jm.verify(transport.startListening, v.times(4))()
        jm.verify(transport.stopListening, v.times(4))()

      )
      test("Activate / Deactivate toggling changes user id if different on further activations", ()->
        game.activate("A USER ID")
        game.deactivate()
        game.deactivate()
        game.activate("A USER ID")
        game.activate("A USER ID")
        game.activate("A USER ID")
        game.deactivate()
        game.deactivate()
        game.activate("A USER ID")
        game.deactivate()
        game.activate("ANOTHER USER ID")
        game.deactivate()
        a.equal(transport.userId, "ANOTHER USER ID")

      )
    )
    suite("updateUserStatus", ()->
      game = null
      event ={}
      setup(()->
        game = new Game(
          id:"A GAME ID"
        ,
          userId:"A USER ID"
        )
        game.set("users",new Backbone.Collection([
            id:"MOCK_USER"
          ,
            id:"OTHER_CHALLENGED_USER"
          ,
            id:"OTHER_OTHER_CHALLENGED_USER"
          ])
        )
        game.generateEvent=JsMockito.mockFunction()
        jm.when(game.generateEvent)(m.anything(), m.anything()).then((ev, data)->
          event
        )
      )
      test("User currently has no status - Generates USERSTATUSCHANGED event using userId and status", ()->
        game.updateUserStatus("MOCK_USER", "TEST STATUS")
        jm.verify(game.generateEvent)(
          Constants.LogEvents.USERSTATUSCHANGED,
          m.hasMember("attributes"
            m.allOf(
              m.hasMember("userId","MOCK_USER"),
              m.hasMember("status","TEST STATUS")
            )
          )

        )
      )
      suite("User currently has other status", ()->
        setup(()->
          game.get("users").get("MOCK_USER").set("status", "SOMETHING ELSE")
        )
        test("Generates event with status and user id.",()->
          game.updateUserStatus("MOCK_USER", "TEST STATUS")
          jm.verify(game.generateEvent)(m.string(), m.hasMember("attributes", m.allOf(m.hasMember("userId","MOCK_USER"),m.hasMember("status", "TEST STATUS"))))
        )
        test("Broadcasts event via transport", ()->
          game.updateUserStatus("MOCK_USER", "TEST STATUS")
          jm.verify(transport.broadcastGameEvent)(m.anything(), event)
        )
        test("Broadcasts with all users including the current one as recipients", ()->
          game.updateUserStatus("MOCK_USER", "TEST STATUS")
          jm.verify(transport.broadcastGameEvent)(m.hasItems("MOCK_USER","OTHER_CHALLENGED_USER","OTHER_OTHER_CHALLENGED_USER"), m.anything())
        )
        test("Current user is only user - still broadcast.", ()->
          g = new Backbone.Model(
            users:new Backbone.Collection([
              id:"MOCK_USER"
            ])
          )
          game.updateUserStatus("MOCK_USER", "TEST STATUS")
          jm.verify(transport.broadcastGameEvent)(m.hasItems("MOCK_USER"), m.anything())
        )
        test("Users have CREATED status are omitted,", ()->
          game.get("users").get("OTHER_CHALLENGED_USER").set("status", Constants.CREATED_STATE)
          game.updateUserStatus("MOCK_USER", "TEST STATUS")
          jm.verify(transport.broadcastGameEvent)(m.allOf(m.not(m.hasItem("OTHER_CHALLENGED_USER")),m.hasItems("MOCK_USER","OTHER_OTHER_CHALLENGED_USER")), m.anything())
        )
        test("User whose status is updated set to CREATED - doesnt broadcast to self, but does to other users without CREATED status", ()->
          game.get("users").get("MOCK_USER").set("status", Constants.CREATED_STATE)
          game.updateUserStatus("MOCK_USER", "TEST STATUS")
          jm.verify(transport.broadcastGameEvent)(m.allOf(m.not(m.hasItem("MOCK_USER")),m.hasItems("OTHER_CHALLENGED_USER","OTHER_OTHER_CHALLENGED_USER")), m.anything())
        )
      )
      test("Game has no users - does nothing",()->
        game.unset("users")
        game.updateUserStatus("MOCK_USER", "TEST STATUS")
        jm.verify(transport.broadcastGameEvent, v.never())(m.anything(), m.anything(), m.anything())

      )
      test("Specified user ID isnt part of game - does nothing",()->
        game.updateUserStatus("NOT_MOCK_USER", "TEST STATUS")
        jm.verify(transport.broadcastGameEvent, v.never())(m.anything(), m.anything(), m.anything())

      )
      test("User currently has same status - does nothing",()->
        game.get("users").get("MOCK_USER").set("status", "TEST STATUS")
        game.updateUserStatus("MOCK_USER", "TEST STATUS")
        jm.verify(transport.broadcastGameEvent, v.never())(m.anything(), m.anything())

      )
    )
  )

)

