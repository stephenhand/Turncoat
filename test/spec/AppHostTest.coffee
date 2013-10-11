
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
      )
      suite("initialise",()->
        teardown(()->
          AppHost.router.on=JsMockito.mockFunction()
        )
        test("setsPrefix", ()->
          AppHost.initialise()
          chai.assert.equal(mocks.rivets.getRivetConfig().prefix, "rv")
        )
        suite("rivetsAdapter", ()->
          test("setsUpAdapter", ()->
            AppHost.initialise()
            chai.assert.isFunction(mocks.rivets.getRivetConfig().adapter.subscribe)
            chai.assert.isFunction(mocks.rivets.getRivetConfig().adapter.unsubscribe)
            chai.assert.isFunction(mocks.rivets.getRivetConfig().adapter.read)
            chai.assert.isFunction(mocks.rivets.getRivetConfig().adapter.publish)
          )
          suite("subscribe", ()->
            test("SimpleBackboneModelAttribute_BindsToModelChangeEventForAttribute", ()->
              AppHost.initialise()
              mod= new Backbone.Model(
                MOCK_ATTRIBUTE:"MOCK_VALUE"
              )
              callback = JsMockito.mockFunction()
              mod.on=JsMockito.mockFunction()
              mocks.rivets.getRivetConfig().adapter.subscribe(mod,"MOCK_ATTRIBUTE",callback)
              JsMockito.verify(mod.on)("change:MOCK_ATTRIBUTE")
            )
            test("SimpleBackboneModelAttributeThatSupportsEvents_BindsToModelAttributesAddRemoveResetEvents", ()->
              AppHost.initialise()
              mod= new Backbone.Model(
                MOCK_ATTRIBUTE:new Backbone.Collection()
              )
              mod.get("MOCK_ATTRIBUTE").on=JsMockito.mockFunction()
              callback = JsMockito.mockFunction()
              mocks.rivets.getRivetConfig().adapter.subscribe(mod,"MOCK_ATTRIBUTE",callback)
              JsMockito.verify(mod.get("MOCK_ATTRIBUTE").on)("add", callback)
              JsMockito.verify(mod.get("MOCK_ATTRIBUTE").on)("remove", callback)
              JsMockito.verify(mod.get("MOCK_ATTRIBUTE").on)("reset", callback)
            )

          )
          suite("unsubscribe", ()->
            test("SimpleBackboneModelAttribute_UnbindsFromModelChangeEventForAttribute", ()->
              AppHost.initialise()
              mod= new Backbone.Model(
                MOCK_ATTRIBUTE:"MOCK_VALUE"
              )
              mod.off=JsMockito.mockFunction()
              callback = JsMockito.mockFunction()
              mocks.rivets.getRivetConfig().adapter.unsubscribe(mod,"MOCK_ATTRIBUTE",callback)
              JsMockito.verify(mod.off)("change:MOCK_ATTRIBUTE")
            )

          )
          suite("read", ()->
            test("SimpleBackboneModelAttribute_Reads", ()->
              AppHost.initialise()
              mod= new Backbone.Model(
                MOCK_ATTRIBUTE:"MOCK_VALUE"
              )
              chai.assert.equal(mocks.rivets.getRivetConfig().adapter.read(mod,"MOCK_ATTRIBUTE"),"MOCK_VALUE")
            )
            test("BackboneCollection_ReadsAsModels", ()->
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
            test("ChainedBackboneModel_ReadsAttribute", ()->
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
            test("MissingChainLink_ReturnsUndefined", ()->
              AppHost.initialise()
              mod= new Backbone.Model(

              )
              chai.assert.isUndefined(mocks.rivets.getRivetConfig().adapter.read(mod,"MOCK_SUBMODEL.MOCK_FURTHER_SUBMODEL.MOCK_ATTRIBUTE"))
            )
            test("ChainedBackboneCollection_ReadsAsModels", ()->
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
          )
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


