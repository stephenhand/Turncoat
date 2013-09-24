define(['underscore', 'backbone', 'lib/turncoat/GameStateModel', 'lib/turncoat/StateRegistry', 'state/FleetAsset'], (_, Backbone, GameStateModel, StateRegistry, FleetAsset)->
  class Player extends GameStateModel


  StateRegistry.registerType("Player", (unvivified)->
    GameStateModel.vivifier(unvivified, Player)
  )

  Player
)