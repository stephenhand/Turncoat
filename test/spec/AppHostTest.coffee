
require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("rivets","AppHost", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      rivetConfig = null
      stubRivets =
        configure:JsMockito.mockFunction()
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

define(["isolate!AppHost", "backbone"],(AppHost, Backbone)->
    mocks = window.mockLibrary["AppHost"]

    suite("AppHost", ()->
      setup(()->
        mocks["setInterval"]=JsMockito.mockFunction()
        mocks["rivets"].configure=JsMockito.mockFunction()
      )
      suite("initialise",()->
        setup(()->
          mocks["UI/routing/Router"].on=JsMockito.mockFunction()
          mocks["UI/routing/Router"].setSubRoute=JsMockito.mockFunction()
          mocks["UI/routing/Router"].getSubRoute=JsMockito.mockFunction()
          mocks["AppState"].on = JsMockito.mockFunction()
          mocks["AppState"].trigger = JsMockito.mockFunction()
        )
        test("configuresRivetsWithAdapter", ()->
          AppHost.initialise()
          JsMockito.verify(mocks["rivets"].configure)(JsHamcrest.Matchers.hasMember("adapter", mocks["UI/rivets/Adapter"]))

        )
        test("configuresRivetsWithPrefix", ()->
          AppHost.initialise()
          JsMockito.verify(mocks["rivets"].configure)(JsHamcrest.Matchers.hasMember("prefix", JsHamcrest.Matchers.string()))
        )
        test("Binds to Router Navigate event", ()->
          AppHost.initialise()
          JsMockito.verify(mocks["UI/routing/Router"].on)("navigate", JsHamcrest.Matchers.func())

        )
        test("Binds to AppState gameDataRequired event", ()->
          AppHost.initialise()
          JsMockito.verify(mocks["AppState"].on)("gameDataRequired", JsHamcrest.Matchers.func())

        )
        suite("gameDataRequired handler", ()->
          gdrHandler = null
          setup(()->
            JsMockito.when(mocks["AppState"].on)("gameDataRequired",  JsHamcrest.Matchers.func()).then((name, h)->
              gdrHandler = h
            )
            AppHost.initialise()
          )
          test("Router already has administration dialog subRoute - does nothing", ()->
            JsMockito.when(mocks["UI/routing/Router"].getSubRoute)("administrationDialogue").then(()->
              {}
            )
            gdrHandler()
            JsMockito.verify(mocks["UI/routing/Router"].setSubRoute, JsMockito.Verifiers.never())(JsHamcrest.Matchers.anything(), JsHamcrest.Matchers.anything())

          )
          test("Router has no administration dialog subRoute - sets administrationDialogue to default", ()->
            JsMockito.when(mocks["UI/routing/Router"].getSubRoute)("administrationDialogue").then(()->)
            gdrHandler()
            JsMockito.verify(mocks["UI/routing/Router"].setSubRoute)("administrationDialogue", "default")

          )
        )
        suite("Router navigate handler", ()->
          handler = null
          setup(()->
            mocks["AppState"].createGame = JsMockito.mockFunction()
            mocks["AppState"].loadUser = JsMockito.mockFunction()
            mocks["AppState"].trigger = JsMockito.mockFunction()
            mocks["AppState"].activate = JsMockito.mockFunction()

            JsMockito.when(mocks["AppState"].createGame)().then(()->
              @game =
                get:(key)->
                  if key is "state" then {}
                  undefined
            )
            AppHost.trigger = JsMockito.mockFunction()
            JsMockito.when(mocks["UI/routing/Router"].on)("navigate", JsHamcrest.Matchers.func()).then((name, h)-> handler = h)
            AppHost.initialise()
          )
          suite("No first (player) part", ()->
            test("triggersUserDataRequired", ()->
              handler(parts:[])
              JsMockito.verify(mocks.AppState.trigger)("userDataRequired")
            )

          )
          suite("First part but no second (game) part", ()->
            test("Loads player", ()->
              handler(parts:["MOCK_USER"])
              JsMockito.verify(mocks.AppState.loadUser)("MOCK_USER")
            )
            test("Triggers gameDataRequired", ()->
              handler(parts:["MOCK_USER"])
              JsMockito.verify(mocks["AppState"].trigger)("gameDataRequired")
            )
            suite("No rootView set", ()->
              test("Calls render", ()->
                r = AppHost.render
                try
                  AppHost.rootView = undefined
                  AppHost.render = JsMockito.mockFunction()
                  handler(parts:["MOCK_USER"])
                  JsMockito.verify(AppHost.render)()
                finally
                  AppHost.render = r
              )

              test("Activates AppState", ()->
                AppHost.rootView = undefined
                AppHost.launch("MOCK_USER","MOCK_GAME")
                JsMockito.verify(mocks.AppState.activate)()
              )
            )
            test("Passes route down to rootView routeChanged", ()->
              AppHost.rootView.routeChanged = JsMockito.mockFunction()
              r =
                parts:["MOCK_USER"]
                subRoutes:
                  administrationDialogue:{}
              handler(r)
              JsMockito.verify(AppHost.rootView.routeChanged)(r)

            )

          )
          suite("First (player) and second (game) parts", ()->
            test("withPlayerAndGameId_createsGameFromState", ()->
              handler(parts:["MOCK_USER","MOCK_GAME"])
              JsMockito.verify(mocks.AppState.createGame)()
            )
          )

        )

      )
      suite("render", ()->
        test("setsRootViewToManOWarTableTopView", ()->
          AppHost.initialise()
          AppHost.render()
          chai.assert.equal(AppHost.rootView.mockId, "MOCK_MANOWARTABLETOPVIEW")
        )
        test("callsRenderOnRootView", ()->
          AppHost.initialise()
          AppHost.render()
          JsMockito.verify(AppHost.rootView.render)()
        )
      )
    )

)


