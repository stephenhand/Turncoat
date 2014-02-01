define(["setInterval", "uuid", "moment", "underscore", "backbone", "lib/turncoat/Constants", "lib/turncoat/Game","lib/turncoat/Factory", "text!data/testInitialState.txt"], (setInterval, UUID, moment, _, Backbone, Constants, Game, Factory, testInitialState)->
  persister = undefined
  POLL_INTERVAL_MILLISECONDS=500
  
  AppState = Backbone.Model.extend(
    activate:()->
      setInterval(()=>
          if (!@get("currentUser")? && !@get("game")?)
            @trigger("userDataRequired")
          else if (!@get("game")?)
            @trigger("gameDataRequired")
        ,POLL_INTERVAL_MILLISECONDS)
      @set("gameTypes", persister.loadGameTypes())

    createGame:()->
      @set("game",Game.fromString(testInitialState))

    loadUser:(id)->
      if (id isnt @get("currentUser")?.get("id"))
        @get("currentUser")?.deactivate()
        @set("currentUser", persister.loadUser(id))
        @get("currentUser").activate()

    loadGameTemplate:(id)->
      if (!id?) then throw new Error("loadGameTemplate requires an ID parameter")
      persister.loadGameTemplate(id)

    loadGame:(id)->
      if (!id?) then throw new Error("loadGame requires an ID parameter")
      if (!@get("currentUser")?.get("id")) then throw new Error("Valid user must be logged in to load a game")
      persister.loadGameState(@get("currentUser").get("id"), id)

    createGameFromTemplate:(state)->
      @get("currentUser").createNewGameFromTemplate(state)

    issueChallenge:(userId, game)->
      if !@get("currentUser")? then throw new Error("Valid user must be logged in to issue a challenge")
      @get("currentUser").issueChallenge(userId, game)
    acceptChallenge:(game)->
      if !@get("currentUser")? then throw new Error("Valid user must be logged in to accept a challenge")
      @get("currentUser").acceptChallenge(game)

  )

  #Singleton

  try
    persister ?= Factory.buildPersister()
  catch e
    persister = {}


  new AppState()
)

