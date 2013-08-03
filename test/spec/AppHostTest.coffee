
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
      )
      suite("launch", ()->
        setup(()->
          mocks["AppState"].createGame = JsMockito.mockFunction()
          mocks["AppState"].loadPlayer = JsMockito.mockFunction()
          mocks["AppState"].trigger = JsMockito.mockFunction()

          JsMockito.when(mocks["AppState"].createGame)().then(()->
            @game =
              state:{}
          )
        )
        test("parameterless_triggersPlayerDataRequired", ()->
          AppHost.trigger = JsMockito.mockFunction()
          AppHost.initialise()
          AppHost.launch()
          JsMockito.verify(mocks.AppState.trigger)("playerDataRequired")

        )
        test("playerOnly_triggersGameDataRequired", ()->
          AppHost.trigger = JsMockito.mockFunction()
          AppHost.initialise()
          AppHost.launch("MOCK_PLAYER")
          JsMockito.verify(mocks.AppState.trigger)("gameDataRequired")

        )
        test("gameIdOnly_notTriggersPlayerDataRequired", ()->
          AppHost.trigger = JsMockito.mockFunction()
          AppHost.initialise()
          AppHost.launch(null ,"MOCK_GAME")
          JsMockito.verify(mocks.AppState.trigger, JsMockito.Verifiers.never())("playerDataRequired")

        )
        test("withPlayerId_loadsPlayer", ()->
          AppHost.trigger = JsMockito.mockFunction()
          AppHost.initialise()
          AppHost.launch("MOCK_PLAYER","MOCK_GAME")
          JsMockito.verify(mocks.AppState.loadPlayer)("MOCK_PLAYER")
        )
        test("withPlayerAndGameId_createsGameFromState", ()->
          AppHost.trigger = JsMockito.mockFunction()
          AppHost.initialise()
          AppHost.launch("MOCK_PLAYER","MOCK_GAME")
          JsMockito.verify(mocks.AppState.createGame)()
        )
        test("withNoPlayerButGameId_createsGameFromStateWithoutLoadingPlayer", ()->
          AppHost.trigger = JsMockito.mockFunction()
          AppHost.initialise()
          AppHost.launch(null,"MOCK_GAME")
          JsMockito.verify(mocks.AppState.createGame)()
          JsMockito.verify(mocks.AppState.loadPlayer, JsMockito.Verifiers.never())(JsHamcrest.Matchers.anything())
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


