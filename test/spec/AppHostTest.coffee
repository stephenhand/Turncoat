
require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("rivets","AppHost", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      stubRivets =
        configure:JsMockito.mockFunction()
        adapters:
          ".":{}
        binders:{}
        formatters:{}
      stubRivets
    )
  )
  Isolate.mapAsFactory("UI/rivets/Adapter","AppHost", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      {}
    )
  )
  Isolate.mapAsFactory("UI/routing/Route","AppHost", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      (path)->
        builtWithPath:path
    )
  )
  Isolate.mapAsFactory("UI/routing/Router","AppHost", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      on:JsMockito.mockFunction()
      setSubRoute:JsMockito.mockFunction()
    )
  )
  Isolate.mapAsFactory("AppState","AppHost", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      get:(key)->
      activate:()->
      on:()->
    )
  )
  Isolate.mapAsFactory("lib/2D/PolygonTools","AppHost", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      mockPolygonTools =
        pointInPoly:(poly,x,y)->
      mockPolygonTools
    )
  )
  Isolate.mapAsFactory("backbone","AppHost", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      actual.history.start=JsMockito.mockFunction()
      actual.Router::on=JsMockito.mockFunction()
      actual
    )
  )
  Isolate.mapAsFactory("UI/ManOWarTableTopView","AppHost", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      mockManOWarTableTopView = ()->
        mmttv = JsMockito.mock(actual)
        mmttv.mockId = "MOCK_MANOWARTABLETOPVIEW"
        mmttv
      mockManOWarTableTopView
    )
  )
)

define(["isolate!AppHost", "matchers", "operators", "assertThat","jsMockito", "verifiers"],(AppHost, m, o, a, jm, v)->
    mocks = window.mockLibrary["AppHost"]

    suite("AppHost", ()->
      setup(()->
        mocks["setInterval"]=jm.mockFunction()
        mocks["rivets"].configure=jm.mockFunction()
      )
      suite("initialise",()->
        setup(()->
          mocks["UI/routing/Router"].on=jm.mockFunction()
          mocks["UI/routing/Router"].setSubRoute=jm.mockFunction()
          mocks["UI/routing/Router"].getSubRoute=jm.mockFunction()
          mocks["AppState"].on = jm.mockFunction()
          mocks["AppState"].trigger = jm.mockFunction()
        )
        test("Moves default rivets dot adapter to colon", ()->
          defaultDotAdapter = mocks["rivets"].adapters["."]
          AppHost.initialise()
          a(mocks["rivets"].adapters[":"], defaultDotAdapter)
          a(mocks["rivets"].adapters["."], m.not(defaultDotAdapter))
        )
        test("Sets dot adapter to custom adapter", ()->
          AppHost.initialise()
          a(mocks["rivets"].adapters["."], mocks["UI/rivets/Adapter"])
        )
        test("Binds to Router Navigate event", ()->
          AppHost.initialise()
          jm.verify(mocks["UI/routing/Router"].on)("navigate", m.func())

        )
        test("Binds to AppState gameDataRequired event", ()->
          AppHost.initialise()
          jm.verify(mocks["AppState"].on)("gameDataRequired", m.func())

        )
        suite("gameDataRequired handler", ()->
          gdrHandler = null
          setup(()->
            jm.when(mocks["AppState"].on)("gameDataRequired",  m.func()).then((name, h)->
              gdrHandler = h
            )
            AppHost.initialise()
          )
          test("Router already has administration dialog subRoute - does nothing", ()->
            jm.when(mocks["UI/routing/Router"].getSubRoute)("administrationDialogue").then(()->
              {}
            )
            gdrHandler()
            jm.verify(mocks["UI/routing/Router"].setSubRoute, v.never())(m.anything(), m.anything())

          )
          test("Router has no administration dialog subRoute - sets administrationDialogue to default", ()->
            jm.when(mocks["UI/routing/Router"].getSubRoute)("administrationDialogue").then(()->)
            gdrHandler()
            jm.verify(mocks["UI/routing/Router"].setSubRoute)("administrationDialogue", "default")

          )
        )
        suite("Router navigate handler", ()->
          handler = null
          setup(()->
            mocks["AppState"].createGame = jm.mockFunction()
            mocks["AppState"].loadUser = jm.mockFunction()
            mocks["AppState"].trigger = jm.mockFunction()
            mocks["AppState"].activate = jm.mockFunction()

            jm.when(mocks["AppState"].createGame)().then(()->
              @game =
                get:(key)->
                  if key is "state" then {}
                  undefined
            )
            AppHost.trigger = jm.mockFunction()
            jm.when(mocks["UI/routing/Router"].on)("navigate", m.func()).then((name, h)-> handler = h)
            AppHost.initialise()
          )
          suite("No first (player) part", ()->
            test("triggersUserDataRequired", ()->
              handler(parts:[])
              jm.verify(mocks.AppState.trigger)("userDataRequired")
            )

          )
          suite("First part but no second (game) part", ()->
            test("Loads player", ()->
              handler(parts:["MOCK_USER"])
              jm.verify(mocks.AppState.loadUser)("MOCK_USER")
            )
            suite("No rootView set", ()->
              test("Calls render", ()->
                r = AppHost.render
                try
                  AppHost.rootView = undefined
                  AppHost.render = jm.mockFunction()
                  jm.when(AppHost.render)().then(()->
                    AppHost.rootView =
                      routeChanged:()->
                  )
                  handler(parts:["MOCK_USER"])
                  jm.verify(AppHost.render)()
                finally
                  AppHost.render = r
              )

              test("Activates AppState", ()->
                AppHost.rootView = undefined
                AppHost.launch("MOCK_USER","MOCK_GAME")
                jm.verify(mocks.AppState.activate)()
              )
            )
            test("Passes route down to rootView routeChanged", ()->
              AppHost.rootView.routeChanged = jm.mockFunction()
              r =
                parts:["MOCK_USER"]
                subRoutes:
                  administrationDialogue:{}
              handler(r)
              jm.verify(AppHost.rootView.routeChanged)(r)

            )

          )
          suite("First (player) and second (game) parts", ()->
            test("withPlayerAndGameId_createsGameFromState", ()->
              handler(parts:["MOCK_USER","MOCK_GAME"])
              jm.verify(mocks.AppState.createGame)()
            )
          )

        )

      )
      suite("render", ()->
        test("setsRootViewToManOWarTableTopView", ()->
          AppHost.initialise()
          AppHost.render()
          a(AppHost.rootView.mockId, "MOCK_MANOWARTABLETOPVIEW")
        )
        test("callsRenderOnRootView", ()->
          AppHost.initialise()
          AppHost.render()
          jm.verify(AppHost.rootView.render)()
        )
      )
    )

)


