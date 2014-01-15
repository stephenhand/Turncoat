define(["underscore", "backbone", "moment", "lib/turncoat/Constants", "lib/turncoat/Factory"], (_, Backbone, moment, Constants, Factory)->
  User = Backbone.Model.extend(
    initialize: (options)->
      transport = Factory.buildTransport(userId:@id)
      persister = Factory.buildPersister()

      @issueChallenge = (userId, game)->
        if !userId? then throw new Error("Target user must be specified to issue a challenge")
        if !game? then throw new Error("Game must be specified to issue a challenge")
        user = game.get("players").find(
          (p)->
            p.get("user").get("id") is userId
        )?.get("user")
        if !user? then throw new Error("Target user must be part of game to issue a challenge")
        user.set("status",Constants.CHALLENGED_STATE)
        transport.sendChallenge(userId, game)
        game.logEvent(moment.utc(),Constants.LogEvents.CHALLENGEISSUED+"::"+@get("id")+"::"+userId, "Challenge Issued")
        persister.saveGameState(@get("id"), game)
      @acceptChallenge = (game)->
        if !game? then throw new Error("Game must be specified to issue a challenge")
        user = game.get("players").find(
          (p)=>
            p.get("user").get("id") is @get("id")
        )?.get("user")
        if !user? then throw new Error("Current user has not been challenged to play this game.")
        user.set("status",Constants.READY_STATE)
        event = game.logEvent(moment.utc(),Constants.LogEvents.USERSTATUSCHANGED+"::"+@get("id")+"::"+Constants.READY_STATE, "Response updated")
        recipients = (player.get("user").get("id") for player in game.get("players").models when player.get("user").get("id") isnt @get("id"))

        if (recipients.length)
          transport.broadcastUserStatus(recipients,
            userid:@get("id")
            status:Constants.READY_STATE
            verifier:
              timestamp:event.get("timestamp")
              id:event.get("id")
              counter:event.get("counter")
          )


    issueChallenge:(userId, game)->

    acceptChallenge:(game)->

  )

  User
)


