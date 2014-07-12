define(['underscore', 'backbone', 'lib/turncoat/GameStateModel', 'lib/turncoat/TypeRegistry', 'state/FleetAsset'], (_, Backbone, GameStateModel, TypeRegistry, FleetAsset)->
  class Player extends GameStateModel

  Player.toString=()->
    "Player"


  TypeRegistry.registerType("Player",  Player)

  Player
)