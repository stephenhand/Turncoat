
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
  Isolate.mapAsFactory("AppState","AppHost", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      get:(key)->
      activate:()->
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
        teardown(()->
          AppHost.router.on=JsMockito.mockFunction()
        )
        test("configuresRivetsWithAdapter", ()->
          AppHost.initialise()
          JsMockito.verify(mocks["rivets"].configure)(JsHamcrest.Matchers.hasMember("adapter", mocks["UI/rivets/Adapter"]))

        )
        test("configuresRivetsWithPrefix", ()->
          AppHost.initialise()
          JsMockito.verify(mocks["rivets"].configure)(JsHamcrest.Matchers.hasMember("prefix", JsHamcrest.Matchers.string()))
        )
        test("bindsRouterEvents", ()->
          o=AppHost.launch
          try
            AppHost.launch=JsMockito.mockFunction()
            JsMockito.when(AppHost.router.on)("route:launch", JsHamcrest.Matchers.func()).then((event, handler)->
              handler.call(AppHost,"MOCK_PLAYERBIT","MOCK_GAMEBIT")
            )
            AppHost.initialise()
            JsMockito.verify(AppHost.launch)("MOCK_PLAYERBIT","MOCK_GAMEBIT")
          finally
            AppHost.launch=o

        )

      )
      suite("launch", ()->
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
          AppHost.initialise()
        )
        test("parameterless_triggersUserDataRequired", ()->

          AppHost.launch()
          JsMockito.verify(mocks.AppState.trigger)("userDataRequired")

        )
        test("userOnly_triggersGameDataRequired", ()->
          AppHost.launch("MOCK_USER")
          JsMockito.verify(mocks.AppState.trigger)("gameDataRequired")

        )
        test("gameIdOnly_notTriggersUserDataRequired", ()->
          AppHost.launch(null ,"MOCK_GAME")
          JsMockito.verify(mocks.AppState.trigger, JsMockito.Verifiers.never())("userDataRequired")

        )
        test("withPlayerId_loadsPlayer", ()->
          AppHost.launch("MOCK_USER","MOCK_GAME")
          JsMockito.verify(mocks.AppState.loadUser)("MOCK_USER")
        )
        test("withPlayerAndGameId_createsGameFromState", ()->
          AppHost.launch("MOCK_USER","MOCK_GAME")
          JsMockito.verify(mocks.AppState.createGame)()
        )
        test("withNoPlayerButGameId_createsGameFromStateWithoutLoadingUser", ()->
          AppHost.launch(null,"MOCK_GAME")
          JsMockito.verify(mocks.AppState.createGame)()
          JsMockito.verify(mocks.AppState.loadUser, JsMockito.Verifiers.never())(JsHamcrest.Matchers.anything())
        )
        test("activatesAppState", ()->
          AppHost.launch("MOCK_USER","MOCK_GAME")
          JsMockito.verify(mocks.AppState.activate)()
        )
      )
      suite("innerRoute", ()->
        mocks["AppState"].get = JsMockito.mockFunction()
        mocks["UI/routing/Route"].func = JsMockito.mockFunction()
        origLaunch = AppHost.launch
        setup(()->
          AppHost.launch = JsMockito.mockFunction()
          AppHost.rootView =
            routeChanged:JsMockito.mockFunction()
          JsMockito.when(mocks["AppState"].get)(JsHamcrest.Matchers.anything()).then(
            (key)->
              switch key
                when "game"
                  id:"MOCK_GAME"
                when "currentUser"
                  id:"MOCK_USER"
          )
        )
        teardown(()->
          AppHost.launch = origLaunch
        )
        test("UserAndGameMatchCurrent_CallsRouteChangedOnRootViewWithRouteBuiltFromInnerRoute", ()->

          AppHost.innerRoute("MOCK_USER","MOCK_GAME", "INNER_ROUTE")
          JsMockito.verify(AppHost.rootView.routeChanged)(JsHamcrest.Matchers.hasMember("builtWithPath", "INNER_ROUTE"))
        )
        test("UserDoesntMatchAppStateCurrent_CallsLaunch", ()->
          AppHost.innerRoute("OTHER_USER","MOCK_GAME", "INNER_ROUTE")
          JsMockito.verify(AppHost.launch)("OTHER_USER","MOCK_GAME")
        )
        test("GameDoesntMatchAppStateCurrent_CallsLaunch", ()->
          AppHost.innerRoute("MOCK_USER","OTHER_GAME", "INNER_ROUTE")
          JsMockito.verify(AppHost.launch)("MOCK_USER","OTHER_GAME")
        )
        test("AppStateCurrentUserNotSet_CallsLaunch", ()->
          JsMockito.when(mocks["AppState"].get)(JsHamcrest.Matchers.anything()).then(
            (key)->
              switch key
                when "game"
                  id:"MOCK_GAME"
          )
          AppHost.innerRoute("MOCK_USER","MOCK_GAME", "INNER_ROUTE")
          JsMockito.verify(AppHost.launch)("MOCK_USER","MOCK_GAME")
        )
        test("AppStateCurrentGameNotSet_CallsLaunch", ()->
          JsMockito.when(mocks["AppState"].get)(JsHamcrest.Matchers.anything()).then(
            (key)->
              switch key
                when "currentUser"
                  id:"MOCK_USER"
          )
          AppHost.innerRoute("MOCK_USER","MOCK_GAME", "INNER_ROUTE")
          JsMockito.verify(AppHost.launch)("MOCK_USER","MOCK_GAME")
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


