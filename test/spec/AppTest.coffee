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
)

define(["isolate!App"],(App)->
    mocks = window.mockLibrary["App"];

    suite("App", ()->
      App.createGame()
      suite("createGame", ()->
        test("initialises", ()->
          App.createGame()
          chai.assert.equal(App.game, mocks["lib/turncoat/Game"]())
        )

      )
      suite("configureRivets",()->
        test("setsPrefix", ()->
          App.configureRivets()
          chai.assert.equal(mocks.rivets.getRivetConfig().prefix, "rv")
        )
        test("setsUpAdapter", ()->
          App.configureRivets()
          chai.assert.isFunction(mocks.rivets.getRivetConfig().adapter.subscribe)
          chai.assert.isFunction(mocks.rivets.getRivetConfig().adapter.unsubscribe)
          chai.assert.isFunction(mocks.rivets.getRivetConfig().adapter.read)
          chai.assert.isFunction(mocks.rivets.getRivetConfig().adapter.publish)

        )
        test("rotateCssFormatterSet", ()->
          App.configureRivets()
          chai.assert.isFunction(mocks.rivets.formatters.rotateCss)
        )
        test("style_topBinderSet",()->
          App.configureRivets()
          chai.assert.isFunction(mocks.rivets.binders.style_top)
        )
        test("style_leftBinderSet",()->
          App.configureRivets()
          chai.assert.isFunction(mocks.rivets.binders.style_left)
        )
        test("style_transformBinderSet",()->
          App.configureRivets()
          chai.assert.isFunction(mocks.rivets.binders.style_transform)
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


