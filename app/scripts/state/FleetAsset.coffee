define(['underscore', 'backbone', 'lib/turncoat/GameStateModel', 'lib/turncoat/StateRegistry', 'state/AssetPosition'], (_, Backbone, GameStateModel, StateRegistry, AssetPosition)->
  class FleetAsset extends GameStateModel
    position : new AssetPosition()

  StateRegistry.registerType("FleetAsset", FleetAsset)
  FleetAsset
)