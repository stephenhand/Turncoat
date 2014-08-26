mockModelInstance = null

require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("UI/administration/CreateGameViewModel","UI/administration/CreateGameView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->

      ()->
        mockModelInstance=
          selectUsersPlayer:JsMockito.mockFunction()
          validate:JsMockito.mockFunction()
          createGame:JsMockito.mockFunction()
        mockModelInstance
    )
  )
)


define(["isolate!UI/administration/CreateGameView", "matchers", "operators", "assertThat", "jsMockito", "verifiers"], (CreateGameView, m, o, a, jm, v)->
  suite("CreateGameView", ()->
    suite("constructor", ()->
      test("setsRootSelectorIfNotSet", ()->
        cgv = new CreateGameView()
        a(cgv.rootSelector, m.string())
      )
      test("setsRootSelectorToOptionIfSet", ()->
        cgv = new CreateGameView(rootSelector:"MOCK_ROOT_SELECTOR")
        a(cgv.rootSelector, "MOCK_ROOT_SELECTOR")
      )
      test("setsTemplate", ()->
        cgv = new CreateGameView()
        a(cgv.template, m.string())
      )
    )
    suite("createModel", ()->
      test("createsModel", ()->
        cgv = new CreateGameView()
        cgv.createModel()
        a(cgv.model, mockModelInstance)
        a(cgv.model)
      )
    )
    suite("selectedPlayerMarker_clicked", ()->
      test("eventTargetIdPresent_callsModelsSelectUsersPlayerWithEventTargetId", ()->
        cgv = new CreateGameView()
        cgv.createModel()
        cgv.selectedPlayerMarker_clicked(
          target:
              id:"MOCK_TARGET_ID"
        )
        jm.verify(cgv.model.selectUsersPlayer)("MOCK_TARGET_ID")
      )
      test("eventTargetIdUndefined_callsModelsSelectUsersPlayerWithNothing", ()->
        cgv = new CreateGameView()
        cgv.createModel()
        cgv.selectedPlayerMarker_clicked(
          target:{}
        )
        jm.verify(cgv.model.selectUsersPlayer)(m.nil())
      )
      test("eventTargetUndefined_throws", ()->
        cgv = new CreateGameView()
        cgv.createModel()
        a(()->
          cgv.selectedPlayerMarker_clicked()
        ,
          m.raisesAnything()
        )
      )
      test("eventUndefined_throws", ()->
        cgv = new CreateGameView()
        cgv.createModel()
        a(()->
          cgv.selectedPlayerMarker_clicked()
        ,
          m.raisesAnything()
        )
      )
    )
  )


)

