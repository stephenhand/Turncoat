define(['underscore', 'backbone', 'lib/turncoat/GameStateModel', 'lib/turncoat/Game', 'lib/turncoat/StateRegistry'], (_, Backbone, GameStateModel, Game, StateRegistry, Player)->
  class ManOWarGameState extends Game
    players:new Backbone.Collection(
      model:Player
    )

    getCurrentControllingUser:()->
      @get("users").findWhere(playerId:@getCurrentControllingPlayer().get("id")) ? throw new Error("User associated with player not found in user list!")


    getCurrentControllingPlayer:()->
      id  = @getLastMove()?.getEndControllingPlayerId()
      if (id?)
        @get("players").get(id) ? throw new Error("Player identified as current not in player list!")
      else
        @get("players").first()


    getCurrentTurnPlayer:()->

  ManOWarGameState.toString=()->
    "ManOWarGameState"
  StateRegistry.registerType("ManOWarGameState",ManOWarGameState)

  ManOWarGameState
)

