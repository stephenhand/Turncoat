define(["underscore", "backbone", "moment", "uuid", "lib/turncoat/Constants", "lib/turncoat/Factory"], (_, Backbone, moment, UUID, Constants, Factory)->
  User = Backbone.Model.extend(
    initialize: (options)->
      transport = Factory.buildTransport(userId:@id)
      persister = Factory.buildPersister()

      @issueChallenge = (userId, game)->
        if !userId? then throw new Error("Target user must be specified to issue a challenge")
        if !game? then throw new Error("Game must be specified to issue a challenge")
        user = game.get("users").get(@)
        if !user? then throw new Error("Sending user must be part of game to issue a challenge")
        user = game.get("users").get(userId)
        if !user? then throw new Error("Target user must be part of game to issue a challenge")
        game.updateUserStatus(userId, Constants.CHALLENGED_STATE)
        transport.sendChallenge(userId, game)

      @acceptChallenge = (game)->
        if !game? then throw new Error("Game must be specified to issue a challenge")
        user = game.get("users").findWhere(
          id:@get("id")
        )
        if !user? then throw new Error("Current user has not been challenged to play this game.")
        game.updateUserStatus(@get("id"), Constants.READY_STATE)

      @createNewGameFromTemplate = (template)->
        template.set("templateId",template.get("id"))
        template.set("id",UUID())
        template.logEvent(template.generateEvent(Constants.LogEvents.GAMECREATED))
        for user in template.get("users").models
          if (user.get("id") is @get("id"))
            user.set("status",Constants.READY_STATE)
          else
            user.set("status",Constants.CREATED_STATE)
        persister.saveGameState(@get("id"), template)


      toggled = null
      @activate = ()->
        @set("gameTemplates", persister.loadGameTemplateList(null, @get("id")))
        @set("games",persister.loadGameList(@get("id")) ? new Backbone.Collection([]))
        persister.on("gameListUpdated", (data)->
          if (data.userId is @get("id"))
            @get("games").set(data.list.models)
        ,@)
        transport.startListening()
        @listenTo(transport,"challengeReceived",(game)=>
          persister.saveGameState(@get("id"), game)
        )

        @deactivate = ()->
          persister.off("gameListUpdated", null, @)
          transport.stopListening()
          @stopListening(transport)
          @activate = toggled
          toggled = @deactivate
          @deactivate = ()->

        toggled = @activate
        @activate = ()->


    issueChallenge:(userId, game)->

    acceptChallenge:(game)->

    createGameFromTemplate:(template)->

    activate:()->
    deactivate:()->

  )

  User
)


