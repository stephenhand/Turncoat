define(["underscore", "backbone", "lib/backboneTools/ModelProcessor", "lib/turncoat/Constants", 'lib/turncoat/GameStateModel', 'lib/turncoat/User', "lib/turncoat/Factory"], (_, Backbone, ModelProcessor, Constants, GameStateModel, User, Factory)->
  class Game extends GameStateModel
    initialize:(attributes, options)->
      persister = null
      transport = null
      super(attributes, options)

      toggled = null
      @activate = (ownerId)->
        if (!ownerId?) then throw new Error("Games must be activated with a user id")
        persister = Factory.buildPersister()
        transport = Factory.buildTransport(
          userId:ownerId
          gameId:@id
        )
        transport.startListening()
        @listenTo(transport, "eventReceived",
          (event)->
            @logEvent(event)
            switch event.get("name")
              when Constants.LogEvents.USERSTATUSCHANGED
                if (@get("users")? && event.get("data") && event.get("data").get("status")?)
                  user = @get("users").get(event.get("data").get("userId"))
                  if (user?)
                    user.set("status",event.get("data").get("status"))
                    persister.saveGameState(ownerId, @)
        )
        @listenTo(persister, "gameUpdated",
          (event)->
            if !event.game? then throw new Error("Game update fired with no game set")
            if event.gameId? and event.gameId is @id and event.userId? and event.userId is ownerId then ModelProcessor.deepUpdate(@, event.game)
        )
        @deactivate = ()->
          persister.stopListening()
          transport.stopListening()
          @stopListening(transport)
          @activate = toggled
          toggled = @deactivate

          persister = null
          transport = null
          @deactivate = ()->

        toggled = @activate
        @activate = ()->

      @updateUserStatus = (userId, status)->
        user = @get("users")?.get(userId)
        if (user? && status? && user.get("status") isnt status)
          event = @generateEvent(Constants.LogEvents.USERSTATUSCHANGED,
            new Backbone.Model(
              userId:userId
              status:status
            )
          )
          recipients = (user.get("id") for user in @get("users").models when (user.get("status") isnt Constants.CREATED_STATE or user.get("id") is transport.userId))
          if (recipients.length)
            transport.broadcastGameEvent(recipients,event)


    activate:()->
    deactivate:()->

    users:new Backbone.Collection(
      model:User
    )

    getCurrentControllingUser:()->
      @getLastMove()?.get("userId")

    logMove:(move)->
      GameStateModel.logEvent(@, move, "moveLog")

    getLastMove:(userid)->
      if @get("moveLog")?
        @get("moveLog").find((l)->(!userid? || userid is l.get("userId")))



  Game
)


