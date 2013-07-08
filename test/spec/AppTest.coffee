require(["isolate","isolateHelper"], (Isolate, Helper)->
  Isolate.mapAsFactory("lib/turncoat/Game","App", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      mockConstructedGame =
        loadState:(state)->
      mockGame = ()->
        mockConstructedGame
      mockGame
    )
  )
  Isolate.mapAsFactory("rivets","App", (actual, modulePath, requestingModulePath)->
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
  Isolate.mapAsFactory("lib/2D/PolygonTools","App", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      mockPolygonTools =
        pointInPoly:(poly,x,y)->
      mockPolygonTools
    )
  )
  Isolate.mapAsFactory("backbone","App", (actual, modulePath, requestingModulePath)->
    Helper.mapAndRecord(actual, modulePath, requestingModulePath, ()->
      actual.history.start=JsMockito.mockFunction()
      actual
    )
  )
)

define(["isolate!App"],(App)->
    mocks = window.mockLibrary["App"];

    suite("App", ()->
      App.createGame()
      suite("createGame", ()->
        test("setsState", ()->
          App.createGame()
          chai.assert.equal(App.game, mocks["lib/turncoat/Game"]())
        )

      )
      suite("initialise",()->
        test("setsPrefix", ()->
          App.initialise()
          chai.assert.equal(mocks.rivets.getRivetConfig().prefix, "rv")
        )
        test("setsUpAdapter", ()->
          App.initialise()
          chai.assert.isFunction(mocks.rivets.getRivetConfig().adapter.subscribe)
          chai.assert.isFunction(mocks.rivets.getRivetConfig().adapter.unsubscribe)
          chai.assert.isFunction(mocks.rivets.getRivetConfig().adapter.read)
          chai.assert.isFunction(mocks.rivets.getRivetConfig().adapter.publish)

        )
        test("rotateCssFormatterSet", ()->
          App.initialise()
          chai.assert.isFunction(mocks.rivets.formatters.rotateCss)
        )
        test("style_topBinderSet",()->
          App.initialise()
          chai.assert.isFunction(mocks.rivets.binders.style_top)
        )
        test("style_leftBinderSet",()->
          App.initialise()
          chai.assert.isFunction(mocks.rivets.binders.style_left)
        )
        test("style_transformBinderSet",()->
          App.initialise()
          chai.assert.isFunction(mocks.rivets.binders.style_transform)
        )
      )
      suite("launch", ()->
        test("parameterless_triggersGameDataRequired", ()->
          App.trigger = JsMockito.mockFunction()
          App.initialise()
          App.launch()
          JsMockito.verify(App.trigger)("gameDataRequired")

        )
        test("withGameId_createsGameFromState", ()->
          App.trigger = JsMockito.mockFunction()
          App.initialise()
          App.launch("MOCK_GAME")
          chai.assert.equal(App.game, mocks["lib/turncoat/Game"]())

        )
      )
      suite("render", ()->
        test("setsRootViewToManOWarTableTopView", ()->
          App.render()
          chai.assert.instanceOf(App.rootView, window.mockLibrary.actuals["UI/ManOWarTableTopView"])
        )
        test("callsRenderOnRootView", ()->
          App.render()
          JsMockito.verify(App.rootView.render)()
        )
      )
    )

)


