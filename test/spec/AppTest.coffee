#rivetConfig = null
#stubRivets =
#  configure:(opts)->
#    rivetConfig = opts
#rivets = stubRivets
#isolate.map("rivets",(actual, modulePath, requestingModulePath)->
#    stubRivets
#)






#AppTest.coffee
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


