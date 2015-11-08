define(["underscore", "backbone", "lib/turncoat/GameStateModel", "lib/turncoat/Constants", "lib/turncoat/Game", "lib/turncoat/TypeRegistry", "state/Player", "rules/RuleBook_v0_0_1"], (_, Backbone, GameStateModel, Constants, Game, TypeRegistry, Player, RuleBook)->
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

    getCurrentTurnMoves:()->
      moves = []
      for m in @get("_eventLog")?.models ? [] when m.get("name") is Constants.LogEvents.MOVE
        if m.get("type") is Constants.MoveTypes.NEW_TURN then break
        moves.push(m)
      moves


    getRuleBook:()->
      RuleBook


  ManOWarGameState.toString=()->
    "ManOWarGameState"
  TypeRegistry.registerType("ManOWarGameState",ManOWarGameState)

  ManOWarGameState
)

