define(['underscore', 'backbone', 'lib/turncoat/Game','lib/turncoat/Factory', 'text!data/testInitialState.txt'], (_, Backbone, Game, Factory, testInitialState)->
  persister = undefined

  AppState = Backbone.Model.extend(
    createGame:()->
      @set("game",new Game())
      @get("game").loadState(testInitialState)
    loadUser:(id)->
      @set("currentUser", persister.loadUser(id))
      @set("gameTemplates", persister.loadGameTemplateList(null, id))
      @set("gameTypes", persister.loadGameTypes())
    loadGameTemplate:(id)->
      if (!id?) then throw new Error("loadGameTemplate requires an ID parameter")
      persister.loadGameTemplate(id)
    createNewGame:(initialState)->
      console.log("Creating new game.")
  )

  #Singleton

  try
    persister ?= Factory.buildPersister()
  catch e
    persister = {}

  new AppState()
)

