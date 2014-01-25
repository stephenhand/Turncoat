define(["underscore", "backbone", "lib/turncoat/Constants", 'lib/turncoat/GameStateModel', 'lib/turncoat/User', "lib/turncoat/Factory"], (_, Backbone, Constants, GameStateModel, User, Factory)->
  class Game extends GameStateModel
    initialize:(attributes, options)->
      transport = Factory.buildTransport(
        gameId:@id
        userId:(options ? {}).userId
      )
      super(attributes, options)

      toggled = null
      @activate = ()->
        transport.startListening()
        @listenTo(transport, "eventReceived",
          (event)->

            #user.set("status",Constants.READY_STATE)
        ,@)

        @deactivate = ()->
          transport.stopListening()
          @stopListening(transport)
          @activate = toggled
          toggled = @deactivate
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
          recipients = (user.get("id") for user in @get("users").models)
          if (recipients.length)
            transport.broadcastEvent(@, recipients,event)


    activate:()->
    deactivate:()->

    users:new Backbone.Collection(
      model:User
    )

    logEvent:(moment, eventName, eventDetails)->
      super(moment, eventName, eventDetails)

  Game
)


