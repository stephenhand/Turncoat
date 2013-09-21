define(['uuid', 'moment', 'underscore', 'backbone', 'lib/turncoat/Game','lib/turncoat/Factory', 'text!data/testInitialState.txt'], (UUID, moment, _, Backbone, Game, Factory, testInitialState)->
  persister = undefined

  AppState = Backbone.Model.extend(
    createGame:()->
      @set("game",new Game())
      @get("game").loadState(testInitialState)
    loadUser:(id)->
      @set("currentUser", persister.loadUser(id))
      @set("gameTemplates", persister.loadGameTemplateList(null, id))
      @set("gameTypes", persister.loadGameTypes())
      @set("games",persister.loadGameList(id))


      persister.off("gameListUpdated", null, @)
      persister.on("gameListUpdated", (data)->
        if (data.userId is @get("currentUser").get("id"))
          @get("games").set(data.list)
      ,@)
    loadGameTemplate:(id)->
      if (!id?) then throw new Error("loadGameTemplate requires an ID parameter")
      persister.loadGameTemplate(id)
    createGameFromTemplate:(state)->
      state.set("templateId",state.get("id"))
      state.set("id",UUID())
      state.logEvent(moment.utc(),"CREATED","Game created locally")
      for player in state.get("players").models when player.get("user")?
        playerUser = player.get("user")
        if (playerUser.get("id") is user)
          player.get("user").set("status","READY")
        else
          player.get("user").set("status","CREATED")
      persister.saveGameState(@get("currentUser").get("id"), state)
  )

  #Singleton

  try
    persister ?= Factory.buildPersister()
  catch e
    persister = {}

  new AppState()
)

