define(['underscore', 'backbone', 'lib/turncoat/GameStateModel', 'lib/turncoat/StateRegistry', 'state/FleetAsset'], (_, Backbone, GameStateModel, StateRegistry, FleetAsset)->
  class Player extends GameStateModel
    fleet:new Backbone.Collection.extend(
      model:FleetAsset
    )


  StateRegistry.registerType("Player", Player)

  Player
)