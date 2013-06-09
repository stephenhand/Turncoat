define(['underscore', 'backbone', 'lib/turncoat/GameStateModel', 'lib/turncoat/StateRegistry', 'state/AssetPosition'], (_, Backbone, GameStateModel, StateRegistry, AssetPosition)->
  class FleetAsset extends GameStateModel
    defaults:
      position:null

  StateRegistry.registerType("FleetAsset", FleetAsset)
  FleetAsset
)