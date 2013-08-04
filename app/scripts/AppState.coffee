define(['underscore', 'backbone', 'lib/turncoat/Game','lib/turncoat/Factory', 'text!data/testInitialState.txt'], (_, Backbone, Game, Factory, testInitialState)->
  persister = undefined
  AppState = Backbone.Model.extend(
    createGame:()->
      @game = new Game()
      @game.loadState(testInitialState)
    loadUser:(id)->
      persister ?= Factory.buildPersister()
      @currentUser= persister.loadUser(id)
  )

  #Singleton
  new AppState()
)

