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
  Isolate.mapAsFactory("UI/routing/Router", "UI/ManOWarTableTopView", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      unsetSubRoute:()->
    )
  )
)


define(["isolate!UI/ManOWarTableTopView", "matchers", "operators", "assertThat","jsMockito", "verifiers"], (ManOWarTableTopView, m, o, a, jm, v)->

  mocks = window.mockLibrary["UI/ManOWarTableTopView"];
  suite("ManOWarTableTopView", ()->
    setup(()->
      mocks.jqueryObjects = []
    )
    suite("constructor", ()->
      test("constructsPlayAreaView", ()->
        MOWTTV = new ManOWarTableTopView()
        a("MOCK_PLAYAREAVIEW", MOWTTV.subViews.get("playAreaView").mockId)
      )
      test("constructsAdministrationDialogueView", ()->
        MOWTTV = new ManOWarTableTopView()
        a("MOCK_ADMINISTRATIONDIALOGUEVIEW", MOWTTV.subViews.get("administrationDialogue").mockId)
      )
    )
    suite("createModel",()->
      test("setsAdministrationDialogueActiveToFalse", ()->
        MOWTTV = new ManOWarTableTopView(
          gameState:{}
        )
        MOWTTV.createModel()
        a(MOWTTV.model.get("administrationDialogueActive"),false)
      )
    )
    suite("createPlayAreaView", ()->
      test("constructsPlayAreaView", ()->
        MOWTTV = new ManOWarTableTopView()
        MOWTTV.createPlayAreaView(
          gameState:{}
        )
        a("MOCK_PLAYAREAVIEW", MOWTTV.subViews.get("playAreaView").mockId)
      )
    )
    suite("createAdministrationView", ()->
      test("constructsAdministrationView", ()->
        MOWTTV = new ManOWarTableTopView()
        MOWTTV.createAdministrationView(
          gameState:{}
        )
        a("MOCK_ADMINISTRATIONDIALOGUEVIEW", MOWTTV.subViews.get("administrationDialogue").mockId)
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
        jm.verify(MOWTTV.subViews.get("playAreaView").render)()
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
        jm.verify(MOWTTV.subViews.get("administrationDialogue").render)()
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
        jm.verify(mocks.jqueryObjects["#administrationDialogue"].jqm)()
      )
      suite("Admin dialog hide handler", ()->
        test("Calls Router unsetSubRoute on administrationDialogue", ()->
          mocks["UI/routing/Router"].unsetSubRoute = jm.mockFunction()
          MOWTTV = new ManOWarTableTopView()
          MOWTTV.createPlayAreaView(
            gameState:{}
          )
          MOWTTV.createAdministrationView(
            gameState:{}
          )
          MOWTTV.render()
          jm.verify(mocks.jqueryObjects["#administrationDialogue"].jqm)(m.hasMember("onHide",
            new JsHamcrest.SimpleMatcher(
              matches:(handler)->
                MOWTTV.model.set=jm.mockFunction()
                try
                  handler()
                  jm.verify(mocks["UI/routing/Router"].unsetSubRoute)("administrationDialogue")
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
        jm.verify(mocks.jqueryObjects["#administrationDialogue"].jqmShow)()
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
        jm.verify(MOWTTV.subViews.get("playAreaView").routeChanged)(route)
      )
      test("No route throws.", ()->

        a(
          ()->MOWTTV.routeChanged()
        ,
          m.raisesAnything()
        )
      )
      suite("Route has no sub views property.", ()->

        test("Sets administrationDialogueActive false", ()->
          MOWTTV.model.set("administrationDialogueActive",true)
          MOWTTV.routeChanged({})
          a(MOWTTV.model.get("administrationDialogueActive"), false)

        )
        test("Doesnt call routeChanged on administrationView", ()->
          MOWTTV.model.set("administrationDialogueActive",true)
          MOWTTV.routeChanged({})
          jm.verify(MOWTTV.subViews.get("administrationDialogue").routeChanged, v.never())(m.anything())
        )
        test("Undefined administrationView doesnt throw", ()->
          MOWTTV.subViews.unset("administrationDialogue")
          a(
            ()->MOWTTV.routeChanged({})
          ,
            m.not(m.raisesAnything())
          )
        )
      )
      suite("Route has no administrationDialog sub view.", ()->
        test("Sets administrationDialogueActive false", ()->
          MOWTTV.model.set("administrationDialogueActive",true)
          MOWTTV.routeChanged({subRoutes:{}})
          a(MOWTTV.model.get("administrationDialogueActive"), false)

        )
        test("Doesnt call routeChanged on administrationView", ()->
          MOWTTV.model.set("administrationDialogueActive",true)
          MOWTTV.routeChanged({subRoutes:{}})
          jm.verify(MOWTTV.subViews.get("administrationDialogue").routeChanged, v.never())(m.anything())
        )
        test("Undefined administrationView doesnt throw", ()->
          MOWTTV.subViews.unset("administrationDialogue")
          a(
            ()->MOWTTV.routeChanged({subRoutes:{}})
          ,
            m.not(m.raisesAnything())
          )
        )
      )
      suite("Route has administrationDialog sub route.", ()->
        test("Sets administrationDialogueActive true", ()->
          MOWTTV.model.set("administrationDialogueActive",false)
          MOWTTV.routeChanged(
            subRoutes:
              administrationDialogue:{}
          )
          a(MOWTTV.model.get("administrationDialogueActive"), true)

        )
        test("Call routeChanged on administrationView with administrationDialog subView", ()->
          MOWTTV.model.set("administrationDialogueActive",false)
          adminRoute = {}
          MOWTTV.routeChanged(
            subRoutes:
              administrationDialogue:adminRoute
          )
          jm.verify(MOWTTV.subViews.get("administrationDialogue").routeChanged)(adminRoute)
        )
        test("Undefined administrationDialogue throws", ()->
          MOWTTV.subViews.unset("administrationDialogue")
          a(
            ()->
              MOWTTV.routeChanged(
                subRoutes:
                  administrationDialogue:{}
              )
          ,
            m.raisesAnything()
          )
        )
      )
      test("Undefined playAreaView throws", ()->
        MOWTTV.subViews.unset("playAreaView")
        a(
          ()->MOWTTV.routeChanged({})
        ,
          m.raisesAnything()
        )
      )
    )
  )
)

