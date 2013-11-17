READY_STATE='READY'
CREATED_STATE='CREATED'
CHALLENGED_STATE='CHALLENGED'

require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("setInterval","AppState", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      ret = ()->
        ret.func.apply(ret, arguments)
      ret
    )
  )
  Isolate.mapAsFactory("lib/turncoat/Game","AppState", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      mockConstructedGame =
        loadState:(state)->
      mockGame = ()->
        mockConstructedGame
      mockGame
    )
  )
  Isolate.mapAsFactory("uuid", "AppState", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      ()->
        "MOCK_GENERATED_ID"
    )
  )
  Isolate.mapAsFactory("moment", "AppState", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      utc:()->
        "MOCK_MOMENT_UTC"
    )
  )
  Isolate.mapAsFactory("lib/turncoat/Factory","AppState", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->

        buildPersister:()->
          p=
            loadUser:JsMockito.mockFunction()
            loadGameTemplateList:JsMockito.mockFunction()
            loadGameTypes:JsMockito.mockFunction()
            loadGameTemplate:JsMockito.mockFunction()
            loadGameList:JsMockito.mockFunction()
            loadGameState:JsMockito.mockFunction()
            saveGameState:JsMockito.mockFunction()
            on:JsMockito.mockFunction()
            off:JsMockito.mockFunction()
          JsMockito.when(p.loadUser)(JsHamcrest.Matchers.anything()).then((a)->
            input:a
            get:(key)->
              if key is "id" then a else null
          )
          JsMockito.when(p.loadGameTemplateList)(JsHamcrest.Matchers.anything()).then((t,a)->
            type:t
            user:a
          )
          JsMockito.when(p.loadGameTypes)().then(()->
            "MOCK_GAME_TYPES"
          )
          JsMockito.when(p.loadGameList)("MOCK_USER").then(()->
            "MOCK_GAME_LIST"
          )
          JsMockito.when(p.loadGameTemplate)(JsHamcrest.Matchers.anything()).then((a)->
            a
          )
          window.mockLibrary["AppState"]["persister"]=p
          p



    )
  )

)

define(['isolate!AppState', "backbone"], (AppState, Backbone)->

  mocks = window.mockLibrary["AppState"]
  currentUserTransport = undefined
  suite("AppState", ()->
    origStopListening = AppState.stopListening
    origListenTo = AppState.listenTo
    setup(()->
      AppState.stopListening = JsMockito.mockFunction()
      AppState.listenTo = JsMockito.mockFunction()
      mocks["lib/turncoat/Factory"].buildTransport=JsMockito.mockFunction()
      JsMockito.when(mocks["lib/turncoat/Factory"].buildTransport)(JsHamcrest.Matchers.anything()).then((opt)->
        currentUserTransport =
          startListening:JsMockito.mockFunction()
          stopListening:JsMockito.mockFunction()
          sendChallenge:JsMockito.mockFunction()
      )
    )
    teardown(()->
      AppState.stopListening =origStopListening
      AppState.listenTo = origListenTo
    )
    suite("createGame", ()->
      test("setsState", ()->
        AppState.createGame()
        chai.assert.equal(AppState.get("game"), mocks["lib/turncoat/Game"]())
      )

    )
    suite("loadUser", ()->
      setup(()->
        mocks["persister"].off=JsMockito.mockFunction()
        mocks["persister"].on=JsMockito.mockFunction()
      )
      test("idString_setsCurrentUserAsPersisterReturnInputVal", ()->
        AppState.loadUser("MOCK_USER")
        chai.assert.equal(AppState.get("currentUser").input, "MOCK_USER")
      )
      test("idString_setsGameTemplatesUsingUserAndNullType", ()->
        AppState.loadUser("MOCK_USER")
        chai.assert.equal(AppState.get("gameTemplates").user, "MOCK_USER")
        chai.assert.equal(AppState.get("gameTemplates").type, null)
      )
      test("idString_setsGameTypes", ()->
        AppState.loadUser("MOCK_USER")
        chai.assert.equal(AppState.get("gameTypes"), "MOCK_GAME_TYPES")
      )
      test("idString_setsGames", ()->
        AppState.loadUser("MOCK_USER")
        chai.assert.equal(AppState.get("games"), "MOCK_GAME_LIST")
      )
      test("removesExistingPersisterGameListUpdatedHandler", ()->
        AppState.loadUser("MOCK_USER")
        JsMockito.verify(mocks["persister"].off)("gameListUpdated",null,AppState)
      )
      test("Creates default transport for user using buildTransport passing in userId",()->
        AppState.loadUser("MOCK_USER")
        JsMockito.verify(mocks["lib/turncoat/Factory"].buildTransport)(JsHamcrest.Matchers.hasMember("userId", "MOCK_USER"))
      )
      test("Transport starts listening",()->
        AppState.loadUser("MOCK_USER")
        JsMockito.verify(currentUserTransport.startListening)()
      )
      test("AppState binds to transport's 'challengeReceived' event",()->
        AppState.loadUser("MOCK_USER")
        JsMockito.verify(AppState.listenTo)(currentUserTransport, "challengeReceived", JsHamcrest.Matchers.func())
      )
      suite("Already has transport set", ()->
        test("Stops listening on previous transport and starts on new one",()->
          AppState.loadUser("MOCK_USER")
          previousTransport = currentUserTransport
          AppState.loadUser("MOCK_SECOND_USER")
          JsMockito.verify(mocks["lib/turncoat/Factory"].buildTransport)(JsHamcrest.Matchers.hasMember("userId", "MOCK_SECOND_USER"))
          JsMockito.verify(previousTransport.stopListening)()
          JsMockito.verify(currentUserTransport.startListening)()
        )
        test("Stops listening to old transport",()->
          AppState.loadUser("MOCK_USER")
          previousTransport = currentUserTransport
          AppState.loadUser("MOCK_SECOND_USER")
          JsMockito.verify(AppState.stopListening)(previousTransport)
        )
      )
      test("appliesNewPersisterGameListUpdatedHandler", ()->
        AppState.loadUser("MOCK_USER")
        AppState.get("games").set=JsMockito.mockFunction()
        JsMockito.verify(mocks["persister"].on)("gameListUpdated",JsHamcrest.Matchers.anything(),AppState)
      )
      suite("challengeReceived handler", ()->
        test("Saves challenge to persister", ()->

          AppState.loadUser("MOCK_USER")
          JsMockito.verify(AppState.listenTo)(currentUserTransport, "challengeReceived", new JsHamcrest.SimpleMatcher(
            describeTo:(d)->
              d.append("challengeReceived handler")
            matches:(handler)->
              try
                game =
                  logEvent:JsMockito.mockFunction()
                handler(game)
                JsMockito.verify(mocks["persister"].saveGameState)("MOCK_USER",game)
                true
              catch e
                false

          ))
        )
        test("Logs the challenge being received on the game", ()->
          AppState.loadUser("MOCK_USER")
          JsMockito.verify(AppState.listenTo)(currentUserTransport, "challengeReceived", new JsHamcrest.SimpleMatcher(
            describeTo:(d)->
              d.append("challengeReceived handler")
            matches:(handler)->
              try
                game =
                  logEvent:JsMockito.mockFunction()
                handler(game)
                JsMockito.verify(game.logEvent)("MOCK_MOMENT_UTC",JsHamcrest.Matchers.string(),JsHamcrest.Matchers.string())
                true
              catch e
                false

          ))
        )
      )
      suite("gameListUpdatedHandler", ()->
        setup(()->
          JsMockito.when(mocks["persister"].loadGameList)("MOCK_USER").then(()->
            new Backbone.Collection()
          )
        )
        test("currentUser_updatesGames", ()->
          AppState.loadUser("MOCK_USER")
          JsMockito.verify(mocks["persister"].on)("gameListUpdated",
            new JsHamcrest.SimpleMatcher(
              matches:(input)->
                AppState.get("games").set=JsMockito.mockFunction()
                newVal=
                  userId:"MOCK_USER"
                  list:new Backbone.Collection([])
                input.call(AppState, newVal)
                try
                  JsMockito.verify(AppState.get("games").set)(newVal.list.models)
                  true
                catch e
                  false
            )
          ,AppState)
        )
        test("otherUser_doesNothing", ()->
          AppState.loadUser("MOCK_USER")
          JsMockito.verify(mocks["persister"].on)("gameListUpdated",
            new JsHamcrest.SimpleMatcher(
              matches:(input)->
                AppState.get("games").set=JsMockito.mockFunction()
                newVal=
                  userId:"OTHER_USER"
                  list:new Backbone.Collection([])
                input.call(AppState, newVal)
                try
                  JsMockito.verify(AppState.get("games").set, JsMockito.Verifiers.never())(JsHamcrest.Matchers.anything())
                  true
                catch e
                  false
            )
          ,AppState)
        )
      )
    )
    suite("loadGameTemplate", ()->
      test("idStringProvided_callsPersisterLoadGameTemplate", ()->
        AppState.loadGameTemplate("MOCK_TEMPLATE_ID")
        JsMockito.verify(mocks["persister"].loadGameTemplate)("MOCK_TEMPLATE_ID")
      )
      test("idObjectProvided_callsPersisterLoadGameTemplate", ()->
        mt={}
        AppState.loadGameTemplate(mt)
        JsMockito.verify(mocks["persister"].loadGameTemplate)(mt)
      )
      test("idNotProvided_throws", ()->
        chai.assert.throws(
          ()->
            AppState.loadGameTemplate()
        )
      )
    )
    suite("loadGame", ()->
      setup(()->
        AppState.set("currentUser",
          new Backbone.Model(
            id:"MOCK_USER"
          )
        )
      )
      test("idStringProvidedUserSet_callsPersisterLoadGameStateWithIdAndUser", ()->
        AppState.loadGame("MOCK_GAME_ID")
        JsMockito.verify(mocks["persister"].loadGameState)("MOCK_USER", "MOCK_GAME_ID")
      )
      test("idObjectProvided_callsPersisterLoadGameStateWithIdObject", ()->
        mg={}
        AppState.loadGame(mg)
        JsMockito.verify(mocks["persister"].loadGameState)("MOCK_USER", mg)
      )
      test("idNotProvided_throws", ()->
        chai.assert.throws(
          ()->
            AppState.loadGame()
        )
      )
      test("userNotSet_throws", ()->
        AppState.unset("currentUser" )
        chai.assert.throws(
          ()->
            AppState.loadGame("MOCK_GAME_ID")
        )
      )
      test("userWithoutIdSet_throws", ()->
        AppState.set("currentUser", "CABBAGEXORS" )
        chai.assert.throws(
          ()->
            AppState.loadGame("MOCK_GAME_ID")
        )
      )
    )
    suite("createGameFromTemplate", ()->
      setup(()->
        AppState.set("currentUser",
          new Backbone.Model(
            id:"MOCK_USER"
          )
        )
        mocks["persister"].saveGameState=JsMockito.mockFunction()
      )
      test("noState_throws", ()->
        chai.assert.throws(()->
          AppState.createGameFromTemplate()
        )
      )

      test("invalidState_throws", ()->
        chai.assert.throws(()->
          AppState.createGameFromTemplate({})
        )
      )

      test("noCurrentUserAndValidState_throws", ()->
        AppState.unset("currentUser")
        state = new Backbone.Model(
          id:"TEMPLATE_ID"
          players:new Backbone.Collection()
        )
        state.logEvent=JsMockito.mockFunction()
        chai.assert.throws(()->
          AppState.createGameFromTemplate(state)
        )
      )

      test("validState_callsPersisterSaveWithIdAsTemplateId", ()->
        state = new Backbone.Model(
          id:"TEMPLATE_ID"
          players:new Backbone.Collection()
        )
        state.logEvent=JsMockito.mockFunction()
        AppState.createGameFromTemplate(state)
        JsMockito.verify(mocks["persister"].saveGameState)("MOCK_USER", new JsHamcrest.SimpleMatcher(
          matches:(s)->
            s.get("templateId") is "TEMPLATE_ID"
        ))
      )

      test("validState_logsCreatedTimeAsCurrentUtc", ()->
        state = new Backbone.Model(
          id:"TEMPLATE_ID"
          players:new Backbone.Collection()
        )
        state.logEvent=JsMockito.mockFunction()
        AppState.createGameFromTemplate(state)
        JsMockito.verify(state.logEvent)("MOCK_MOMENT_UTC",JsHamcrest.Matchers.string(),JsHamcrest.Matchers.string())

      )

      test("validStateOnlyCreatorPlaying_setsCurrentUserToReadyState", ()->
        state = new Backbone.Model(
          id:"TEMPLATE_ID"
          players:new Backbone.Collection([
            new Backbone.Model(
              user:new Backbone.Model(
                id:"MOCK_USER"
              )
            )
          ])
        )
        state.logEvent=JsMockito.mockFunction()
        AppState.createGameFromTemplate(state)
        JsMockito.verify(mocks["persister"].saveGameState)("MOCK_USER", new JsHamcrest.SimpleMatcher(
          matches:(s)->
            s.get("players").find((p)->p.get("user").get("id") is "MOCK_USER").get("user").get("status") is READY_STATE
        ))
      )
      test("validStateOnlyOtherUsersPlaying_setsOtherUsersToCreatedState", ()->
        state = new Backbone.Model(
          id:"TEMPLATE_ID"
          players:new Backbone.Collection([
            new Backbone.Model(
              user:new Backbone.Model(
                id:"OTHER_USER"
              )
            ),
            new Backbone.Model(
              user:new Backbone.Model(
                id:"ANOTHER_OTHER_USER"
              )
            )
          ])
        )
        state.logEvent=JsMockito.mockFunction()
        AppState.createGameFromTemplate(state)
        JsMockito.verify(mocks["persister"].saveGameState)("MOCK_USER", new JsHamcrest.SimpleMatcher(
          matches:(s)->
            s.get("players").find((p)->p.get("user").get("id") is "OTHER_USER").get("user").get("status") is CREATED_STATE
            s.get("players").find((p)->p.get("user").get("id") is "ANOTHER_OTHER_USER").get("user").get("status") is CREATED_STATE
        ))
      )
      test("validStateCreatorPlayingOthers_setsCurrentUserToReadyStateAndOthersToCreated", ()->
        state = new Backbone.Model(
          id:"TEMPLATE_ID"
          players:new Backbone.Collection([
            new Backbone.Model(
              user:new Backbone.Model(
                id:"OTHER_USER"
              )
            ),
            new Backbone.Model(
              user:new Backbone.Model(
                id:"ANOTHER_OTHER_USER"
              )
            ),
            new Backbone.Model(
              user:new Backbone.Model(
                id:"MOCK_USER"
              )
            )
          ])
        )
        state.logEvent=JsMockito.mockFunction()
        AppState.createGameFromTemplate(state)
        JsMockito.verify(mocks["persister"].saveGameState)("MOCK_USER", new JsHamcrest.SimpleMatcher(
          matches:(s)->
            s.get("players").find((p)->p.get("user").get("id") is "MOCK_USER").get("user").get("status") is READY_STATE
            s.get("players").find((p)->p.get("user").get("id") is "OTHER_USER").get("user").get("status") is CREATED_STATE
            s.get("players").find((p)->p.get("user").get("id") is "ANOTHER_OTHER_USER").get("user").get("status") is CREATED_STATE
        ))
      )
    )
    suite("activate", ()->
      setup(()->
        mocks["setInterval"].func = JsMockito.mockFunction()
        AppState.trigger = JsMockito.mockFunction()
      )
      test("setsPollingInterval", ()->
        AppState.activate()
        JsMockito.verify(mocks["setInterval"].func)(JsHamcrest.Matchers.func(), JsHamcrest.Matchers.number())
      )
      suite("polling call", ()->
        test("noUserOrGameSet_triggersUserDataRequired", ()->
          AppState.unset("currentUser")
          AppState.unset("game")
          AppState.activate()
          JsMockito.verify(mocks["setInterval"].func)(new JsHamcrest.SimpleMatcher(
            matches:(poll)->
              try
                poll()
                JsMockito.verify(AppState.trigger)("userDataRequired")
                true
              catch e
                false
          ), JsHamcrest.Matchers.number())
        )
        test("noUserOrGameSet_doesntTriggerGameDataRequired", ()->
          AppState.unset("currentUser")
          AppState.unset("game")
          AppState.activate()
          JsMockito.verify(mocks["setInterval"].func)(new JsHamcrest.SimpleMatcher(
            matches:(poll)->
              try
                poll()
                JsMockito.verify(AppState.trigger, JsMockito.Verifiers.never())("gameDataRequired")
                true
              catch e
                false
          ), JsHamcrest.Matchers.number())
        )
        test("userButNoGameSet_triggersGameDataRequired", ()->
          AppState.set("currentUser", "MOCK_USER")
          AppState.unset("game")
          AppState.activate()
          JsMockito.verify(mocks["setInterval"].func)(new JsHamcrest.SimpleMatcher(
            matches:(poll)->
              try
                poll()
                JsMockito.verify(AppState.trigger)("gameDataRequired")
                true
              catch e
                false
          ), JsHamcrest.Matchers.number())
        )
        test("userButNoGameSet_doesnTriggersUserDataRequired", ()->
          AppState.set("currentUser", "MOCK_USER")
          AppState.unset("game")
          AppState.activate()
          JsMockito.verify(mocks["setInterval"].func)(new JsHamcrest.SimpleMatcher(
            matches:(poll)->
              try
                poll()
                JsMockito.verify(AppState.trigger, JsMockito.Verifiers.never())("userDataRequired")
                true
              catch e
                false
          ), JsHamcrest.Matchers.number())
        )
        test("UserAndGameSet_DoesNothing", ()->
          AppState.set("currentUser", "MOCK_USER")
          AppState.set("game", {})
          AppState.activate()
          JsMockito.verify(mocks["setInterval"].func)(new JsHamcrest.SimpleMatcher(
            matches:(poll)->
              try
                poll()
                JsMockito.verify(AppState.trigger, JsMockito.Verifiers.never())("userDataRequired")
                JsMockito.verify(AppState.trigger, JsMockito.Verifiers.never())("gameDataRequired")
                true
              catch e
                false
          ), JsHamcrest.Matchers.number())
        )
        test("GameSetButNoUser_DoesNothing", ()->
          AppState.set("currentUser", "MOCK_USER")
          AppState.set("game", {})
          AppState.activate()
          JsMockito.verify(mocks["setInterval"].func)(new JsHamcrest.SimpleMatcher(
            matches:(poll)->
              try
                poll()
                JsMockito.verify(AppState.trigger, JsMockito.Verifiers.never())("userDataRequired")
                JsMockito.verify(AppState.trigger, JsMockito.Verifiers.never())("gameDataRequired")
                true
              catch e
                false
          ), JsHamcrest.Matchers.number())
        )
      )
    )
    suite("issueChallenge", ()->
      game = {}
      setup(()->
        game = new Backbone.Model(
          players:new Backbone.Collection([
            user:new Backbone.Model(
              id:"CHALLENGED_USER"
            )

          ])
        )
        game.logEvent=JsMockito.mockFunction()
        AppState.loadUser("MOCK_USER")
      )
      test("Current user not set - throws",()->
        AppState.unset("currentUser")
        chai.assert.throw(()->
          AppState.issueChallenge("CHALLENGED_USER", {})
        )
      )
      test("Challenged user not set - throws",()->
        chai.assert.throw(()->
          AppState.issueChallenge(undefined, {})
        )
      )
      test("Game not set - throws",()->
        chai.assert.throw(()->
          AppState.issueChallenge("CHALLENGED_USER")
        )
      )
      test("Challenged user not assigned to a player in game - throws",()->
        chai.assert.throw(()->
          AppState.issueChallenge("NOT_CHALLENGED_USER")
        )
      )
      test("Valid input - calls transport sendChallenge with same user & game",()->

        AppState.issueChallenge("CHALLENGED_USER", game)
        JsMockito.verify(currentUserTransport.sendChallenge)("CHALLENGED_USER",game)
      )
      test("Valid input - sets challenged player status to challenged",()->
        AppState.issueChallenge("CHALLENGED_USER", game)
        chai.assert.equal(game.get("players").at(0).get("user").get("status"),CHALLENGED_STATE)
      )
      test("Valid input - calls transport sendChallenge with game after status set",()->
        AppState.issueChallenge("CHALLENGED_USER", game)
        JsMockito.verify(currentUserTransport.sendChallenge)("CHALLENGED_USER",new JsHamcrest.SimpleMatcher(
          describeTo:(d)->
            d.append("game")
          matches:(g)->
            g.get("players").at(0).get("user").get("status") is CHALLENGED_STATE
        ))
      )
      test("Valid input - saves game",()->
        AppState.issueChallenge("CHALLENGED_USER", game)
        JsMockito.verify(mocks["persister"].saveGameState)("MOCK_USER",game)
      )
      test("Valid input - logs on game", ()->
        AppState.issueChallenge("CHALLENGED_USER", game)
        JsMockito.verify(game.logEvent)("MOCK_MOMENT_UTC",JsHamcrest.Matchers.string(),JsHamcrest.Matchers.string())
      )
    )
  )


)

