require(["isolate","isolateHelper","backbone"], (Isolate, Helper, Backbone)->
  Isolate.mapAsFactory("UI/ManOWarTableTopViewModel", "UI/ManOWarTableTopView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      x = Backbone.Model.extend(
        initialize:()->

      )
      x
    )
  )
  Isolate.mapAsFactory("UI/PlayAreaView", "UI/ManOWarTableTopView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      ()->
        mockId:"MOCK_PLAYAREAVIEW"
        render:JsMockito.mockFunction()
        routeChanged:JsMockito.mockFunction()
    )
  )
  Isolate.mapAsFactory("UI/administration/AdministrationDialogueView", "UI/ManOWarTableTopView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      ()->
        mockId:"MOCK_ADMINISTRATIONDIALOGUEVIEW"
        render:JsMockito.mockFunction()
        routeChanged:JsMockito.mockFunction()
    )
  )
)


define(['isolate!UI/ManOWarTableTopView'], (ManOWarTableTopView)->

  mocks = window.mockLibrary["UI/ManOWarTableTopView"];
  suite("ManOWarTableTopView", ()->
    suite("constructor", ()->
      test("constructsPlayAreaView", ()->
        MOWTTV = new ManOWarTableTopView()
        chai.assert.equal("MOCK_PLAYAREAVIEW", MOWTTV.subViews.get("playAreaView").mockId)
      )
      test("constructsAdministrationDialogueView", ()->
        MOWTTV = new ManOWarTableTopView()
        chai.assert.equal("MOCK_ADMINISTRATIONDIALOGUEVIEW", MOWTTV.subViews.get("administrationView").mockId)
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
        chai.assert.equal("MOCK_PLAYAREAVIEW", MOWTTV.subViews.get("playAreaView").mockId)
      )
    )
    suite("createAdministrationView", ()->
      test("constructsAdministrationView", ()->
        MOWTTV = new ManOWarTableTopView()
        MOWTTV.createAdministrationView(
          gameState:{}
        )
        chai.assert.equal("MOCK_ADMINISTRATIONDIALOGUEVIEW", MOWTTV.subViews.get("administrationView").mockId)
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
        JsMockito.verify(MOWTTV.subViews.get("playAreaView").render)()
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
        JsMockito.verify(MOWTTV.subViews.get("administrationView").render)()
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
      suite("Admin dialog hide handler", ()->
        test("ModelSet_SetsModelAdministrationDialogActivePropertyToFalse", ()->
          MOWTTV = new ManOWarTableTopView()
          MOWTTV.createPlayAreaView(
            gameState:{}
          )
          MOWTTV.createAdministrationView(
            gameState:{}
          )
          MOWTTV.render()
          JsMockito.verify(mocks.jqueryObjects["#administrationDialogue"].jqm)(JsHamcrest.Matchers.hasMember("onHide",
            new JsHamcrest.SimpleMatcher(
              matches:(handler)->
                MOWTTV.model.set=JsMockito.mockFunction()
                try
                  handler()
                  JsMockito.verify(MOWTTV.model.set)("administrationDialogueActive", false)
                  true
                catch e
                  false
              )
            )
          )
        )
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
    suite("routeChanged", ()->
      MOWTTV = null
      setup(()->
        MOWTTV = new ManOWarTableTopView()
        MOWTTV.createPlayAreaView(
          gameState:{}
        )
        MOWTTV.createAdministrationView(
          gameState:{}
        )
        MOWTTV.render()
      )
      test("Calls routeChanged with same route on Play Area sub view.", ()->
        route = {}
        MOWTTV.routeChanged(route)
        JsMockito.verify(MOWTTV.subViews.get("playAreaView").routeChanged)(route)
      )
      test("No route throws.", ()->

        chai.assert.throws(()->MOWTTV.routeChanged())
      )
      suite("Route has no sub views property.", ()->

        test("Sets administrationDialogueActive false", ()->
          MOWTTV.model.set("administrationDialogueActive",true)
          MOWTTV.routeChanged({})
          chai.assert.isFalse(MOWTTV.model.get("administrationDialogueActive"))

        )
        test("Doesnt call routeChanged on administrationView", ()->
          MOWTTV.model.set("administrationDialogueActive",true)
          MOWTTV.routeChanged({})
          JsMockito.verify(MOWTTV.subViews.get("administrationView").routeChanged, JsMockito.Verifiers.never())(JsHamcrest.Matchers.anything())
        )
        test("Undefined administrationView doesnt throw", ()->
          MOWTTV.subViews.unset("administrationView")
          chai.assert.doesNotThrow(()->MOWTTV.routeChanged({}))
        )
      )
      suite("Route has no administrationDialog sub view.", ()->
        test("Sets administrationDialogueActive false", ()->
          MOWTTV.model.set("administrationDialogueActive",true)
          MOWTTV.routeChanged({subRoutes:{}})
          chai.assert.isFalse(MOWTTV.model.get("administrationDialogueActive"))

        )
        test("Doesnt call routeChanged on administrationView", ()->
          MOWTTV.model.set("administrationDialogueActive",true)
          MOWTTV.routeChanged({subRoutes:{}})
          JsMockito.verify(MOWTTV.subViews.get("administrationView").routeChanged, JsMockito.Verifiers.never())(JsHamcrest.Matchers.anything())
        )
        test("Undefined administrationView doesnt throw", ()->
          MOWTTV.subViews.unset("administrationView")
          chai.assert.doesNotThrow(()->MOWTTV.routeChanged({subRoutes:{}}))
        )
      )
      suite("Route has administrationDialog sub route.", ()->
        test("Sets administrationDialogueActive true", ()->
          MOWTTV.model.set("administrationDialogueActive",false)
          MOWTTV.routeChanged(
            subRoutes:
              administrationDialogue:{}
          )
          chai.assert.isTrue(MOWTTV.model.get("administrationDialogueActive"))

        )
        test("Call routeChanged on administrationView with administrationDialog subView", ()->
          MOWTTV.model.set("administrationDialogueActive",false)
          adminRoute = {}
          MOWTTV.routeChanged(
            subRoutes:
              administrationDialogue:adminRoute
          )
          JsMockito.verify(MOWTTV.subViews.get("administrationView").routeChanged)(adminRoute)
        )
        test("Undefined administrationView throws", ()->
          MOWTTV.subViews.unset("administrationView")
          chai.assert.throws(
            ()->
              MOWTTV.routeChanged(
                subRoutes:
                  administrationDialogue:{}
              )
          )
        )
      )
      test("Undefined playAreaView throws", ()->
        MOWTTV.subViews.unset("playAreaView")
        chai.assert.throws(()->MOWTTV.routeChanged({}))
      )
    )
  )

)

