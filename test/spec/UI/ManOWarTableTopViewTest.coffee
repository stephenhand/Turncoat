require(["isolate","isolateHelper","backbone"], (Isolate, Helper, Backbone)->
  #Isolate.mapAsFactory("UI/ManOWarTableTopViewModel", "UI/ManOWarTableTopView", (actual, modulePath, requestingModulePath)->
  #  Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
  #    ()->
  #      actual
  #  )
  #)
  Isolate.mapAsFactory("UI/PlayAreaView", "UI/ManOWarTableTopView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      ()->
        mockId:"MOCK_PLAYAREAVIEW"
        render:JsMockito.mockFunction()
    )
  )
  Isolate.mapAsFactory("UI/administration/AdministrationDialogueView", "UI/ManOWarTableTopView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      ()->
        mockId:"MOCK_ADMINISTRATIONDIALOGUEVIEW"
        render:JsMockito.mockFunction()
    )
  )
)


define(['isolate!UI/ManOWarTableTopView'], (ManOWarTableTopView)->

  mocks = window.mockLibrary["UI/ManOWarTableTopView"];
  suite("ManOWarTableTopView", ()->
    suite("constructor", ()->
      test("doesntConstructPlayAreaViewParameterless", ()->
        MOWTTV = new ManOWarTableTopView()
        chai.assert.isUndefined(MOWTTV.playAreaView)
      )
      test("doesntConstructPlayAreaViewWithoutGameState", ()->
        MOWTTV = new ManOWarTableTopView({})
        chai.assert.isUndefined(MOWTTV.playAreaView)
      )
      test("doesntConstructAdministrationDialogueViewWithoutGameState", ()->
        MOWTTV = new ManOWarTableTopView({})
        chai.assert.isUndefined(MOWTTV.administrationView)
      )
      test("constructsPlayAreaViewIfGameStateProvided", ()->
        MOWTTV = new ManOWarTableTopView(
          gameState:{}
        )
        chai.assert.equal("MOCK_PLAYAREAVIEW", MOWTTV.playAreaView.mockId)
      )
      test("constructsAdministrationDialogueViewIfGameStateProvided", ()->
        MOWTTV = new ManOWarTableTopView(
          gameState:{}
        )
        chai.assert.equal("MOCK_ADMINISTRATIONDIALOGUEVIEW", MOWTTV.administrationView.mockId)
      )
    )
    suite("createModel",()->
      test("setsAdministrationDialogueActiveToFalse", ()->
        MOWTTV = new ManOWarTableTopView(
          gameState:{}
        )
        MOWTTV.createModel()
        chai.assert.equal(MOWTTV.model.get("administrationDialogueActive"),false)
      )
    )
    suite("createPlayAreaView", ()->
      test("constructsPlayAreaView", ()->
        MOWTTV = new ManOWarTableTopView()
        MOWTTV.createPlayAreaView(
          gameState:{}
        )
        chai.assert.equal("MOCK_PLAYAREAVIEW", MOWTTV.playAreaView.mockId)
      )
    )
    suite("createAdministrationView", ()->
      test("constructsAdministrationView", ()->
        MOWTTV = new ManOWarTableTopView()
        MOWTTV.createAdministrationView(
          gameState:{}
        )
        chai.assert.equal("MOCK_ADMINISTRATIONDIALOGUEVIEW", MOWTTV.administrationView.mockId)
      )
    )
    suite("render", ()->
      test("rendersPlayAreaView", ()->
        MOWTTV = new ManOWarTableTopView()
        MOWTTV.createPlayAreaView(
          gameState:{}
        )
        MOWTTV.createAdministrationView(
          gameState:{}
        )
        MOWTTV.render()
        JsMockito.verify(MOWTTV.playAreaView.render)()
      )
      test("rendersAdminstrationAreaView", ()->
        MOWTTV = new ManOWarTableTopView()
        MOWTTV.createPlayAreaView(
          gameState:{}
        )
        MOWTTV.createAdministrationView(
          gameState:{}
        )
        MOWTTV.render()
        JsMockito.verify(MOWTTV.administrationView.render)()
      )
      test("initialisesAdministrationJQModal", ()->
        MOWTTV = new ManOWarTableTopView()
        MOWTTV.createPlayAreaView(
          gameState:{}
        )
        MOWTTV.createAdministrationView(
          gameState:{}
        )
        MOWTTV.render()
        JsMockito.verify(mocks.jqueryObjects["#administrationDialogue"].jqm)()
      )
    )
    suite("modelAdministrationDialogueActiveChange", ()->
      test("trueCallsJqmShowOnAdminModal", ()->
        MOWTTV = new ManOWarTableTopView()
        MOWTTV.createPlayAreaView(
          gameState:{}
        )
        MOWTTV.createAdministrationView(
          gameState:{}
        )
        MOWTTV.render()

        MOWTTV.model.set("administrationDialogueActive",true)
        JsMockito.verify(mocks.jqueryObjects["#administrationDialogue"].jqmShow)()
      )
    )
  )

)

