

require(["isolate","isolateHelper"], (Isolate, Helper)->
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
      {
        buildPersister:()->
          p=
            loadUser:JsMockito.mockFunction()
            loadGameTemplateList:JsMockito.mockFunction()
            loadGameTypes:JsMockito.mockFunction()
            loadGameTemplate:JsMockito.mockFunction()
            loadGameList:JsMockito.mockFunction()
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
      }
    )
  )

)

define(['isolate!AppState'], (AppState)->

  mocks = window.mockLibrary["AppState"]
  suite("AppState", ()->
    suite("createGame", ()->
      test("setsState", ()->
        AppState.createGame()
        chai.assert.equal(AppState.get("game"), mocks["lib/turncoat/Game"]())
      )

    )
    suite("loadUser", ()->
      setup(()->
        window.mockLibrary["AppState"]["persister"].off=JsMockito.mockFunction()
        window.mockLibrary["AppState"]["persister"].on=JsMockito.mockFunction()
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
      test("appliesNewPersisterGameListUpdatedHandler", ()->
        AppState.loadUser("MOCK_USER")
        AppState.get("games").set=JsMockito.mockFunction()
        JsMockito.verify(mocks["persister"].on)("gameListUpdated",JsHamcrest.Matchers.anything(),AppState)
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
                  JsMockito.verify(AppState.get("games").set)(newVal.list)
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
    suite("createGameFromTemplate", ()->
      setup(()->
        AppState.set("currentUser",
          new Backbone.Model(
            id:"MOCK_USER"
          )
        )
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

    )
  )


)

