
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
      get:(key)->
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
        test("adapterReadReadsSimpleBackboneModelAttribute", ()->
          AppHost.initialise()
          mod= new Backbone.Model(
            MOCK_ATTRIBUTE:"MOCK_VALUE"
          )
          chai.assert.equal(mocks.rivets.getRivetConfig().adapter.read(mod,"MOCK_ATTRIBUTE"),"MOCK_VALUE")
        )
        test("adapterReadReadsBackboneCollectionAsModels", ()->
          AppHost.initialise()
          mod= new Backbone.Collection([
            a:3
          ,
            a:5
          ,
            a:9
          ])
          chai.assert.equal(mocks.rivets.getRivetConfig().adapter.read(mod)[0].get("a"),3)
          chai.assert.equal(mocks.rivets.getRivetConfig().adapter.read(mod)[1].get("a"),5)
          chai.assert.equal(mocks.rivets.getRivetConfig().adapter.read(mod)[2].get("a"),9)
        )
        test("adapterReadReadsChainedBackboneModelAttribute", ()->
          AppHost.initialise()
          mod= new Backbone.Model(
            MOCK_SUBMODEL:new Backbone.Model(
              MOCK_FURTHER_SUBMODEL:new Backbone.Model(
                MOCK_ATTRIBUTE:"MOCK_NESTED_VALUE"
              )
            )
            MOCK_ATTRIBUTE:"MOCK_VALUE"

          )
          chai.assert.equal(mocks.rivets.getRivetConfig().adapter.read(mod,"MOCK_SUBMODEL.MOCK_FURTHER_SUBMODEL.MOCK_ATTRIBUTE"),"MOCK_NESTED_VALUE")
        )
        test("adapterReadReturnsUndefinedIfMissingChainLink", ()->
          AppHost.initialise()
          mod= new Backbone.Model(

          )
          chai.assert.isUndefined(mocks.rivets.getRivetConfig().adapter.read(mod,"MOCK_SUBMODEL.MOCK_FURTHER_SUBMODEL.MOCK_ATTRIBUTE"))
        )
        test("adapterReadReadsChainedBackboneCollectionAsModels", ()->
          AppHost.initialise()
          mod= new Backbone.Model(
            MOCK_SUBMODEL:new Backbone.Model(
              MOCK_FURTHER_SUBMODEL:new Backbone.Model(
                MOCK_COLLECTION:new Backbone.Collection([
                  a:2
                ,
                  a:4
                ,
                  a:8
                ])
              )
            )
            MOCK_ATTRIBUTE:"MOCK_VALUE"
            MOCK_COLLECTION:new Backbone.Collection([
              a:3
            ,
              a:5
            ,
              a:9
            ])

          )
          chai.assert.equal(mocks.rivets.getRivetConfig().adapter.read(mod,"MOCK_SUBMODEL.MOCK_FURTHER_SUBMODEL.MOCK_COLLECTION")[0].get("a"),2)
          chai.assert.equal(mocks.rivets.getRivetConfig().adapter.read(mod,"MOCK_SUBMODEL.MOCK_FURTHER_SUBMODEL.MOCK_COLLECTION")[1].get("a"),4)
          chai.assert.equal(mocks.rivets.getRivetConfig().adapter.read(mod,"MOCK_SUBMODEL.MOCK_FURTHER_SUBMODEL.MOCK_COLLECTION")[2].get("a"),8)
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
              get:(key)->
                if key is "state" then {}
                undefined
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


