
require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("rivets","AppHost", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      rivetConfig = null
      stubRivets =
        configure:(opts)=>
          rivetConfig = opts
        getRivetConfig:()->
          rivetConfig
        binders:{}
        formatters:{}
      stubRivets
    )
  )
  Isolate.mapAsFactory("AppState","AppHost", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      {}
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

define(["isolate!AppHost"],(AppHost)->
    mocks = window.mockLibrary["AppHost"]

    suite("AppHost", ()->
      suite("initialise",()->
        teardown(()->
          AppHost.router.on=JsMockito.mockFunction()
        )
        test("setsPrefix", ()->
          AppHost.initialise()
          chai.assert.equal(mocks.rivets.getRivetConfig().prefix, "rv")
        )
        test("setsUpAdapter", ()->
          AppHost.initialise()
          chai.assert.isFunction(mocks.rivets.getRivetConfig().adapter.subscribe)
          chai.assert.isFunction(mocks.rivets.getRivetConfig().adapter.unsubscribe)
          chai.assert.isFunction(mocks.rivets.getRivetConfig().adapter.read)
          chai.assert.isFunction(mocks.rivets.getRivetConfig().adapter.publish)

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

          JsMockito.when(mocks["AppState"].createGame)().then(()->
            @game =
              state:{}
          )
        )
        test("parameterless_triggersUserDataRequired", ()->
          AppHost.trigger = JsMockito.mockFunction()
          AppHost.initialise()
          AppHost.launch()
          JsMockito.verify(mocks.AppState.trigger)("userDataRequired")

        )
        test("userOnly_triggersGameDataRequired", ()->
          AppHost.trigger = JsMockito.mockFunction()
          AppHost.initialise()
          AppHost.launch("MOCK_USER")
          JsMockito.verify(mocks.AppState.trigger)("gameDataRequired")

        )
        test("gameIdOnly_notTriggersUserDataRequired", ()->
          AppHost.trigger = JsMockito.mockFunction()
          AppHost.initialise()
          AppHost.launch(null ,"MOCK_GAME")
          JsMockito.verify(mocks.AppState.trigger, JsMockito.Verifiers.never())("userDataRequired")

        )
        test("withPlayerId_loadsPlayer", ()->
          AppHost.trigger = JsMockito.mockFunction()
          AppHost.initialise()
          AppHost.launch("MOCK_USER","MOCK_GAME")
          JsMockito.verify(mocks.AppState.loadUser)("MOCK_USER")
        )
        test("withPlayerAndGameId_createsGameFromState", ()->
          AppHost.trigger = JsMockito.mockFunction()
          AppHost.initialise()
          AppHost.launch("MOCK_USER","MOCK_GAME")
          JsMockito.verify(mocks.AppState.createGame)()
        )
        test("withNoPlayerButGameId_createsGameFromStateWithoutLoadingUser", ()->
          AppHost.trigger = JsMockito.mockFunction()
          AppHost.initialise()
          AppHost.launch(null,"MOCK_GAME")
          JsMockito.verify(mocks.AppState.createGame)()
          JsMockito.verify(mocks.AppState.loadUser, JsMockito.Verifiers.never())(JsHamcrest.Matchers.anything())
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


