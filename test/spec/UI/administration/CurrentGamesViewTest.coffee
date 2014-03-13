mockModelInstance = null

require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("UI/administration/CurrentGamesViewModel","UI/administration/CurrentGamesView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      ()->
        mockModelInstance =
          selectGame:JsMockito.mockFunction()

    )
  )
)

define(["isolate!UI/administration/CurrentGamesView", "jsMockito", "jsHamcrest", "chai"], (CurrentGamesView, jm, h, c)->
  mocks = window.mockLibrary["UI/administration/CurrentGamesView"]
  m = h.Matchers
  a = c.assert
  v = jm.Verifiers
  suite("CurrentGamesView", ()->

    suite("constructor", ()->
      test("Sets root selector if not set", ()->
        cgv = new CurrentGamesView()
        a.isString(cgv.rootSelector)
      )
      test("Sets root selector to option if set", ()->
        cgv = new CurrentGamesView(rootSelector:"MOCK_ROOT_SELECTOR")
        a.equal(cgv.rootSelector, "MOCK_ROOT_SELECTOR")
      )
      test("Sets template", ()->
        cgv = new CurrentGamesView()
        a.isString(cgv.template)
      )
    )
    suite("createModel", ()->
      test("Creates model", ()->
        cgv = new CurrentGamesView()
        cgv.createModel()
        a.equal(cgv.model, mockModelInstance)
        a.isNotNull(cgv.model)
      )
    )
    suite("gameListItem_clicked", ()->
      test("EventTarget id present - calls models selectGame with event current targetId", ()->
        cgv = new CurrentGamesView()
        cgv.createModel()
        cgv.gameListItem_clicked(
          currentTarget:
            id:"MOCK_TARGET_ID"
        )
        jm.verify(cgv.model.selectGame)("MOCK_TARGET_ID")
      )
      
      test("Event target id undefined - calls models selectGame with nothing", ()->
        cgv = new CurrentGamesView()
        cgv.createModel()
        cgv.gameListItem_clicked(
          currentTarget:{}
        )
        jm.verify(cgv.model.selectGame)(m.nil())
      )
      test("eventTargetUndefined_throws", ()->
        cgv = new CurrentGamesView()
        cgv.createModel()
        a.throws(()->
          cgv.gameListItem_clicked({})
        )
      )
      test("eventUndefined_throws", ()->
        cgv = new CurrentGamesView()
        cgv.createModel()
        a.throws(()->
          cgv.gameListItem_clicked()
        )
      )
    )

  )
)

