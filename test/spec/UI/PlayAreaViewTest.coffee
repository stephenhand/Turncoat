define(['isolate!UI/PlayAreaView', 'lib/turncoat/GameStateModel'], (PlayAreaView, GameStateModel)->
  suite("PlayAreaView", ()->
    suite("createModel", ()->
      test("setsModel", ()->
        pav = new PlayAreaView(gameState:JsMockito.mock(GameStateModel))
        pav.createModel()
        chai.assert.isDefined(pav.model)
      )

      test("gameStateNotSet_Throws", ()->
        pav = new PlayAreaView()

        chai.assert.throw(()->
          pav.createModel()
        )
      )
    )
  )


)

