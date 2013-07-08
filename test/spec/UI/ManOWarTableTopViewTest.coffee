require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("UI/PlayAreaView", "UI/ManOWarTableTopView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      ()->
        mockId:"MOCK_PLAYAREAVIEW"
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
      test("constructsPlayAreaViewIfGameStateProvided", ()->
        MOWTTV = new ManOWarTableTopView(
          gameState:{}
        )
        chai.assert.equal("MOCK_PLAYAREAVIEW", MOWTTV.playAreaView.mockId)
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
  )

)

