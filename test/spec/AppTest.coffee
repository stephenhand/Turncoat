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
      App.start()
      suite("start", ()->
        test("initialises", ()->
          App.start()
          chai.assert.equal(App.game, mocks["lib/Game"]())
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
    )

)


