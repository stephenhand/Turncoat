define(["setInterval", "uuid", "moment", "underscore", "backbone", "lib/turncoat/Game","lib/turncoat/Factory", "text!data/testInitialState.txt"], (setInterval, UUID, moment, _, Backbone, Game, Factory, testInitialState)->
  persister = undefined
  transport = undefined
  CHALLENGED_STATE="CHALLENGED"
  READY_STATE="READY"
  CREATED_STATE="CREATED"
  POLL_INTERVAL_MILLISECONDS=500
  
  AppState = Backbone.Model.extend(
    activate:()->
      setInterval(()=>
          if (!@get("currentUser")? && !@get("game")?)
            @trigger("userDataRequired")
          else if (!@get("game")?)
            @trigger("gameDataRequired")
        ,POLL_INTERVAL_MILLISECONDS)

    createGame:()->
      @set("game",new Game())
      @get("game").loadState(testInitialState)

    loadUser:(id)->
      @set("currentUser", persister.loadUser(id))
      @set("gameTemplates", persister.loadGameTemplateList(null, id))
      @set("gameTypes", persister.loadGameTypes())
      @set("games",persister.loadGameList(id) ? new Backbone.Collection([]))
      persister.off("gameListUpdated", null, @)
      persister.on("gameListUpdated", (data)->
        if (data.userId is @get("currentUser").get("id"))
          @get("games").set(data.list.models)
      ,@)
      if transport?
        transport.stopListening()
        @stopListening(transport)
      transport = Factory.buildTransport(userId:id)
      @listenTo(transport,"challengeReceived",(game)=>

        game.logEvent(moment.utc(),"INVITERECEIVED::"+id,"Game created locally")
        persister.saveGameState(@get("currentUser").get("id"), game)
      )
      transport.startListening()

    loadGameTemplate:(id)->
      if (!id?) then throw new Error("loadGameTemplate requires an ID parameter")
      persister.loadGameTemplate(id)

    loadGame:(id)->
      if (!id?) then throw new Error("loadGame requires an ID parameter")
      if (!@get("currentUser")?.get("id")) then throw new Error("Valid user must be logged in to load a game")
      persister.loadGameState(@get("currentUser").get("id"), id)

    createGameFromTemplate:(state)->
      state.set("templateId",state.get("id"))
      state.set("id",UUID())
      state.logEvent(moment.utc(),CREATED_STATE,"Game created locally")
      for player in state.get("players").models when player.get("user")?
        playerUser = player.get("user")
        if (playerUser.get("id") is @get("currentUser").get("id"))
          player.get("user").set("status",READY_STATE)
        else
          player.get("user").set("status",CREATED_STATE)
      persister.saveGameState(@get("currentUser").get("id"), state)

    issueChallenge:(userId, game)->
      if !@get("currentUser")? then throw new Error("Valid user must be logged in to issue a challenge")
      if !userId? then throw new Error("Target user must be specified to issue a challenge")
      if !game? then throw new Error("Game must be specified to issue a challenge")
      user = game.get("players").find((p)->
        p.get("user").get("id") is userId
      )?.get("user")
      if !user? then throw new Error("Target user must be part of game to issue a challenge")
      user.set("status",CHALLENGED_STATE)
      transport.sendChallenge(userId, game)
      persister.saveGameState(@get("currentUser").get("id"), game)
      game.logEvent(moment.utc(),"INVITESENT::"+userId, "Game created locally")
  )

  #Singleton

  try
    persister ?= Factory.buildPersister()
  catch e
    persister = {}


  new AppState()
)

