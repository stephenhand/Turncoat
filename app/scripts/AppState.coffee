define(['underscore', 'backbone', 'lib/turncoat/Game', 'text!data/testInitialState.txt'], (_, Backbone, Game, testInitialState)->
  AppState = Backbone.Model.extend(
    createGame:()->
      @game = new Game()
      @game.loadState(testInitialState)
    loadPlayer:()->
  )

  #Singleton
  new AppState()
)

