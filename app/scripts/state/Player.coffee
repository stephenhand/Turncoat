define(['underscore', 'backbone', 'lib/turncoat/GameStateModel', 'lib/turncoat/TypeRegistry', 'state/FleetAsset'], (_, Backbone, GameStateModel, TypeRegistry, FleetAsset)->
  class Player extends GameStateModel
    initialize:()->
      if !@get("user")? then @set("user", new Backbone.Model())

    getCurrentTurnMoves:()->
      moves = []
      for m in @getRoot().get("moveLog")?.models ? []
        if m.get("type") is Constants.NEW_TURN then break
        if @get("user").get("userId") is m.get("userId") then moves.push(m)
      moves

  Player.toString=()->
    "Player"

  TypeRegistry.registerType("Player",  Player)

  Player
)