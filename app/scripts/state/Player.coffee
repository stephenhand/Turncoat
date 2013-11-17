define(['underscore', 'backbone', 'lib/turncoat/GameStateModel', 'lib/turncoat/StateRegistry', 'state/FleetAsset'], (_, Backbone, GameStateModel, StateRegistry, FleetAsset)->
  class Player extends GameStateModel

  Player.toString=()->
    "Player"


  StateRegistry.registerType("Player",  Player)

  Player
)