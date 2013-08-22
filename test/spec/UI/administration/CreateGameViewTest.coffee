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


define(['isolate!UI/administration/CreateGameView','backbone'], (CreateGameView, Backbone)->
  suite("CreateGameView", ()->
    suite("constructor", ()->
      test("setsRootSelectorIfNotSet", ()->
        cgv = new CreateGameView()
        chai.assert.isString(cgv.rootSelector)
      )
      test("setsRootSelectorToOptionIfSet", ()->
        cgv = new CreateGameView(rootSelector:"MOCK_ROOT_SELECTOR")
        chai.assert.equal(cgv.rootSelector, "MOCK_ROOT_SELECTOR")
      )
      test("setsTemplate", ()->
        cgv = new CreateGameView()
        chai.assert.isString(cgv.template)
      )
    )
    suite("createModel", ()->
      test("createsModel", ()->
        cgv = new CreateGameView()
        cgv.createModel()
        chai.assert.equal(cgv.model, mockModelInstance)
        chai.assert.isNotNull(cgv.model)
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
        JsMockito.verify(cgv.model.selectUsersPlayer)("MOCK_TARGET_ID")
      )
      test("eventTargetIdUndefined_callsModelsSelectUsersPlayerWithNothing", ()->
        cgv = new CreateGameView()
        cgv.createModel()
        cgv.selectedPlayerMarker_clicked(
          target:{}
        )
        JsMockito.verify(cgv.model.selectUsersPlayer)(JsHamcrest.Matchers.nil())
      )
      test("eventTargetUndefined_throws", ()->
        cgv = new CreateGameView()
        cgv.createModel()
        chai.assert.throws(()->
          cgv.selectedPlayerMarker_clicked({})
        )
      )
      test("eventUndefined_throws", ()->
        cgv = new CreateGameView()
        cgv.createModel()
        chai.assert.throws(()->
          cgv.selectedPlayerMarker_clicked()
        )
      )
    )
    suite("confirmCreateGame_clicked", ()->
      test("validatesModel", ()->
        cgv = new CreateGameView()
        cgv.createModel()
        cgv.confirmCreateGame_clicked()
        JsMockito.verify(cgv.model.validate)()
      )
      test("validModel_callsModelCreateGame", ()->
        cgv = new CreateGameView()
        cgv.createModel()
        JsMockito.when(cgv.model.validate)().then(()->true)
        cgv.confirmCreateGame_clicked()
        JsMockito.verify(cgv.model.createGame)()
      )
      test("invalidModel_neverCallsModelCreateGame", ()->
        cgv = new CreateGameView()
        cgv.createModel()
        JsMockito.when(cgv.model.validate)().then(()->false)
        cgv.confirmCreateGame_clicked()
        JsMockito.verify(cgv.model.createGame, JsMockito.Verifiers.never())()
      )
    )
  )


)

