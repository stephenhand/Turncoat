define(["App","lib/Game"], (App,Game)->
    #AppTest.coffee    
    suite("App", ()->
        suite("start", ()->
            test("initialises", ()->
                App.start()
                chai.assert.instanceOf(App.game, Game)
            )

        )


    )

)