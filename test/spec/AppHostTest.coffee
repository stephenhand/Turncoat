
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


