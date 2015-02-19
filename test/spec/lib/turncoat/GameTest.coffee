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

  Isolate.mapAsFactory("lib/backboneTools/ModelProcessor", "lib/turncoat/Game", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      {}
    )
  )
)
define(["isolate!lib/turncoat/Game", "matchers", "operators", "assertThat", "jsMockito", "verifiers", "lib/turncoat/Constants"],
(Game, m, o, a, jm, v, Constants)->
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
        stopListening:jm.mockFunction()
        on:jm.mockFunction()
      mocks["lib/turncoat/Factory"].buildTransport = jm.mockFunction()
      jm.when(mocks["lib/turncoat/Factory"].buildTransport)(m.anything(), m.anything()).then((opts)->
        transport
      )
      mocks["lib/turncoat/Factory"].buildPersister = jm.mockFunction()
      jm.when(mocks["lib/turncoat/Factory"].buildPersister)().then((opts)->
        persister
      )
      mocks["lib/backboneTools/ModelProcessor"].deepUpdate = jm.mockFunction()

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
      test("Doesnt build transport before activation", ()->
        new Game(
          id:"A GAME ID"
        ,{})
        jm.verify(mocks["lib/turncoat/Factory"].buildTransport, v.never())(m.anything())
      )
      test("Doesnt build persister before activation", ()->
        new Game(
          id:"A GAME ID"
        ,{})
        jm.verify(mocks["lib/turncoat/Factory"].buildPersister, v.never())()
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
        a(
          ()->
            game.activate()
        ,
          m.raisesAnything()
        )
      )
      test("No options supplied - builds transport with game id and supplied owner id", ()->
        game.activate("A USER ID")
        jm.verify(mocks["lib/turncoat/Factory"].buildTransport)(
          m.nil()
        ,
          m.allOf(
            m.hasMember("gameId","A GAME ID")
            m.hasMember("userId","A USER ID")
          )
        )
      )
      test("Options supplied without transportKey - builds transport with game id and supplied owner id", ()->
        game.activate("A USER ID", {})
        jm.verify(mocks["lib/turncoat/Factory"].buildTransport)(
          m.nil()
        ,
          m.allOf(
            m.hasMember("gameId","A GAME ID")
            m.hasMember("userId","A USER ID")
          )
        )
      )
      test("Options supplied with transportKey - builds transport using specified key with game id and supplied owner id", ()->
        game.activate("A USER ID", transportKey:"A KEY")
        jm.verify(mocks["lib/turncoat/Factory"].buildTransport)(
          "A KEY"
        ,
          m.allOf(
            m.hasMember("gameId","A GAME ID")
            m.hasMember("userId","A USER ID")
          )
        )
      )
      test("Builds persister", ()->
        game.activate("A USER ID")
        jm.verify(mocks["lib/turncoat/Factory"].buildPersister)()
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
        jm.verify(mocks["lib/turncoat/Factory"].buildTransport)(m.nil(), m.hasMember("userId","A USER ID"))
        jm.verify(mocks["lib/turncoat/Factory"].buildTransport, v.never())(m.nil(), m.hasMember("userId","ANOTHER USER ID"))
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
          a(
            ()->
              handler({})
          ,
            m.raisesAnything()
          )
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
            a(game.get("users").get("MOCK USER").get("status"), m.nil())
            a(game.get("users").get("NOT MOCK USER").get("status"), m.nil())
          )
          test("User Id missing - does nothing", ()->
            event.get("data").unset("userId")
            handler.call(game,event)
            a(game.get("users").get("MOCK USER").get("status"), m.nil())
            a(game.get("users").get("NOT MOCK USER").get("status"), m.nil())
          )
          test("Status missing - does nothing", ()->
            game.get("users").get("MOCK USER").set("status", "EXISTING STATUS")
            event.get("data").unset("status")
            handler.call(game,event)
            a(game.get("users").get("MOCK USER").get("status"), "EXISTING STATUS")
            a(game.get("users").get("NOT MOCK USER").get("status"), m.nil())
          )
          test("User Id is not in game user list - does nothing", ()->
            event.get("data").set("userId", "MISSING USER")
            handler.call(game,event)
            a(game.get("users").get("MOCK USER").get("status"), m.nil())
            a(game.get("users").get("NOT MOCK USER").get("status"), m.nil())
          )
          test("Game has no user collection - does nothing", ()->
            game.unset("users")
            handler.call(game,event)
            a(game.get("users"), m.nil())
          )
          test("Specified user exists and status set - sets status", ()->
            handler.call(game,event)
            a(game.get("users").get("MOCK USER").get("status"),"MOCK STATUS")
          )
          test("Specified user exists and status set - save's game state via persister using transport's user id", ()->
            handler.call(game,event)
            jm.verify(persister.saveGameState)("A USER ID", game)
          )
        )
        suite("Event is MOVE", ()->
          setup(()->
            event.set("name", Constants.LogEvents.MOVE)
          )
          test("Data missing - does not throw", ()->
            a(
              ()->
                handler.call(game,event)
              ,
                m.not(m.raisesAnything())
            )
          )
          test("tests not finished", ()->
            a()
          )
        )
      )

      test("Listens to persister's 'gameUpdated' handler", ()->
        game.listenTo = jm.mockFunction()
        game.activate("A USER ID")
        jm.verify(game.listenTo)(persister, "gameUpdated", m.func())
      )
      suite("gameUpdated handler", ()->
        handler = null
        event = null
        setup(()->
          game.listenTo = jm.mockFunction()
          jm.when(game.listenTo)(persister, "gameUpdated", m.func()).then((t, e, f)=>
            handler = f
          )
          game.activate("A USER ID")
          game.logEvent = jm.mockFunction()
          event = new Backbone.Model()
        )
        test("Event userId not set - does nothing", ()->
          handler.call(game,
            gameId:"A GAME ID"
            game:{}
          )
          jm.verify(mocks["lib/backboneTools/ModelProcessor"].deepUpdate, v.never())(m.anything(), m.anything())
        )
        test("Event userId not owner id - does nothing", ()->
          handler.call(game,
            gameId:"A GAME ID"
            userId:"ANOTHER USER ID"
            game:{}
          )
          jm.verify(mocks["lib/backboneTools/ModelProcessor"].deepUpdate, v.never())(m.anything(), m.anything())
        )
        test("Event gameId not set - does nothing", ()->
          handler.call(game,
            userId:"A USER ID"
            game:{}
          )
          jm.verify(mocks["lib/backboneTools/ModelProcessor"].deepUpdate, v.never())(m.anything(), m.anything())
        )
        test("Event gameId not game id - does nothing", ()->
          handler.call(game,
            gameId:"ANOTHER GAME ID"
            userId:"A USER ID"
            game:{}
          )
          jm.verify(mocks["lib/backboneTools/ModelProcessor"].deepUpdate, v.never())(m.anything(), m.anything())
        )
        test("Game not set - throws", ()->
          a(
            ()->
              handler.call(game,
                gameId:"A GAME ID"
                userId:"A USER ID"
              )
          ,
            m.raisesAnything()
          )
        )
        test("Event gameId matches game id, Event userId matches owner id and event game set - deepUpdates game with event", ()->
          g = {}
          handler.call(game,
            gameId:"A GAME ID"
            userId:"A USER ID"
            game:g
          )

          jm.verify(mocks["lib/backboneTools/ModelProcessor"].deepUpdate)(game, g)
        )
      )
      suite("deactivate", ()->
        test("Calls persister's 'stopListening'", ()->
          game.activate("A USER ID")
          game.deactivate()
          jm.verify(persister.stopListening)()
        )
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
        jm.verify(mocks["lib/turncoat/Factory"].buildTransport)(m.nil(), m.hasMember("userId","ANOTHER USER ID"))

      )
    )
    suite("updateUserStatus", ()->
      game = null
      event ={}
      setup(()->
        game = new Game(
          id:"A GAME ID"
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
      test("Game not activated - throws", ()->
        a(
          ()->
            game.updateUserStatus("MOCK_USER", "TEST STATUS")
        ,
          m.raisesAnything()
        )
      )
      suite("Game activated", ()->
        setup(()->
          game.activate("A USER ID")
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
    suite("submitMove", ()->
      game = null
      event = null
      setup(()->
        event = {}
        game = new Game(
          id:"A GAME ID"
        )
        game.generateEvent = jm.mockFunction()
        jm.when(game.generateEvent)(Constants.LogEvents.MOVE, m.anything()).thenReturn(event)
      )
      test("Game not activated - throws", ()->
        game.set("users", new Backbone.Collection([
            name:"A"
          ])
        )
        a(
          ()->
            game.submitMove()
        ,
          m.raisesAnything()
        )
      )
      suite("Game activated", ()->
        setup(()->

          game.activate("A USER ID")
        )
        test("Called without move - throws", ()->
          game.set("users", new Backbone.Collection([
              name:"A"
            ])
          )
          a(
            ()->
              game.submitMove()
          ,
            m.raisesAnything()
          )
        )
        test("Called when game has no users collection - throws", ()->
          a(
            ()->
              game.submitMove({})
          ,
            m.raisesAnything()
          )
        )
        test("Called when game has empty users collection - throws", ()->
          game.set("users", new Backbone.Collection([]))
          a(
            ()->
              game.submitMove({})
          ,
            m.raisesAnything()
          )
        )
        suite("Called with move when game has valid users collection", ()->
          move = null
          setup(()->
            move = {}
            game.set("users", new Backbone.Collection([
              id:"USER A"
            ,
              id:"USER B"
            ,
              id:"USER C"
            ]))
          )
          test("Calls generateEvent with move type and move as data", ()->
            game.submitMove(move)
            jm.verify(game.generateEvent)(Constants.LogEvents.MOVE, move)
          )
          test("Calls transports broadcastGameEvent with generated event to all users, specified buy an array of all their ids", ()->
            game.submitMove(move)
            jm.verify(transport.broadcastGameEvent)(m.equivalentArray(["USER A","USER B","USER C"]), event)
          )
        )
      )

    )
    suite("logMove", ()->
      suite("Move log is valid Backbone Collection", ()->
        game = null
        setup(()->
          game = new Game(
            moveLog:new Backbone.Collection([
              userId:"MOCK_MOVER"
              details:"MOCK_DETAILS"
              timestamp:{moment:"MOCK_TIME"}
            ])
          )
        )
        test("Adds new move to start", ()->
          event = new Backbone.Model()
          game.logMove(event)
          a(game.get("moveLog").length, 2)

          a(game.get("moveLog").at(0), event)

        )
        test("Preserves Existing Events", ()->
          game.logMove({})
          a(game.get("moveLog").at(1).get("userId"), "MOCK_MOVER")
        )

      )
      test("No existing move log - Creates new log", ()->
        game = new Game()
        event = new Backbone.Model()
        game.logMove(event)
        a(game.get("moveLog").length, 1)
        a(game.get("moveLog").at(0), event)
      )
      test("Invalid move log - Throws", ()->
        game = new Game(
          moveLog:{}
        )
        a(
          ()->
            game.logMove({})
        ,
          m.raisesAnything()
        )
      )
    )
    suite("getLatestMove", ()->
      suite("Game without move log", ()->
        test("No userId - returns undefined", ()->
          game = new Game()
          a(game.getLastMove(), m.nil())
        )
        test("userId specified - returns undefined", ()->
          game = new Game()
          a(game.getLastMove("MOVER_NAME"), m.nil())
        )
      )

      suite("Game with move log", ()->
        game = null
        setup(()->
          game = new Game(
            moveLog:new Backbone.Collection([
              userId:"MOCK_MOVER"
              details:"MOCK_DETAILS"
              timestamp:{moment:"MOCK_TIME"}
            ,
              userId:"MOCK_MOVER_2"
              details:"MOCK_DETAILS_2"
              timestamp:{moment:"MOCK_TIME_2"}
            ,
              userId:"MOCK_MOVER_2"
              details:"MOCK_DETAILS_3"
              timestamp:{moment:"MOCK_TIME_3"}
            ])
          )
        )
        test("No userId - returns top move", ()->
          ret= game.getLastMove()
          a("MOCK_MOVER",ret.get("userId"))
          a("MOCK_DETAILS",ret.get("details"))
          a("MOCK_TIME",ret.get("timestamp").moment)
        )
        test("UserId that exists in log - returns top move with that userId of that name", ()->
          ret= game.getLastMove("MOCK_MOVER_2")
          a("MOCK_MOVER_2",ret.get("userId"))
          a("MOCK_DETAILS_2",ret.get("details"))
          a("MOCK_TIME_2",ret.get("timestamp").moment)
        )
        test("UserId that doesnt exist in log - returns undefined", ()->
          a(game.getLastMove("MOCK_MOVER_3"), m.nil())
        )
      )
    )
    suite("getRuleBook", ()->
      test("always throws", ()->
        a(
          ()->
            new Game().getRuleBook({})
        ,
          m.raisesAnything()
        )
      )
    )
  )


)

