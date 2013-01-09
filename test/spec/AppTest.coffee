rivetConfig = null
stubRivets =
  configure:(opts)->
    rivetConfig = opts
rivets = stubRivets
###
context=testUtils.createContext([
  rivets:stubRivets
])
###


#AppTest.coffee
define(["App","lib/Game"],(App,Game)->


    suite("App", ()->
      App.start()
      suite("start", ()->
        test("initialises", ()->
          App.start()
          chai.assert.instanceOf(App.game, Game)
        )

      )
      suite("configureRivets",()->
        test("setsPrefix", ()->
          App.configureRivets()
          chai.assert.eq(rivetConfig.prefix, "rv")
        )
      )
    )
    ###
    #ret = 1337
    context(["App","lib/Game"],(App,Game)->
        ret = suite("App", ()->
          App.start()
          suite("start", ()->
              test("initialises", ()->
                  App.start()
                  chai.assert.instanceOf(App.game, Game)
              )

          )
          suite("configureRivets",()->
              test("setsPrefix", ()->
                  App.configureRivets()
                  chai.assert.eq(rivetConfig.prefix, "rv")
              )
          )
        )
        ret


    )
    ###
    #ret
)


