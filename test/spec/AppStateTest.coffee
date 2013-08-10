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
  Isolate.mapAsFactory("lib/turncoat/Factory","AppState", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      {
        buildPersister:()->
          p=
            loadUser:JsMockito.mockFunction()
            loadGameTemplateList:JsMockito.mockFunction()
            loadGameTypes:JsMockito.mockFunction()
            loadGameTemplate:JsMockito.mockFunction()
          JsMockito.when(p.loadUser)(JsHamcrest.Matchers.anything()).then((a)->
            input:a
          )
          JsMockito.when(p.loadGameTemplateList)(JsHamcrest.Matchers.anything()).then((t,a)->
            type:t
            user:a
          )
          JsMockito.when(p.loadGameTypes)().then(()->
            "MOCK_GAME_TYPES"
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
  )


)

