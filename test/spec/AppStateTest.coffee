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
          JsMockito.when(p.loadUser)(JsHamcrest.Matchers.anything()).then((a)->
            input:a
          )
          JsMockito.when(p.loadGameTemplateList)(JsHamcrest.Matchers.anything()).then((t,a)->
            type:t
            user:a
          )
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
    )
  )


)

