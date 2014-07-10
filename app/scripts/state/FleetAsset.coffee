define(['underscore', 'backbone', 'lib/turncoat/GameStateModel', 'lib/turncoat/StateRegistry', 'state/AssetPosition'], (_, Backbone, GameStateModel, StateRegistry, AssetPosition)->
  class FleetAsset extends GameStateModel
    defaults:
      position:null

    getOwningPlayer:(game)->
      c = @getOwnershipChain(game)
      _.find(c, (ci)->ci instanceof StateRegistry["Player"]) ? null

    getAvailableActions:()->


  FleetAsset.toString=()->
    "FleetAsset"

  StateRegistry.registerType("FleetAsset", FleetAsset)


  FleetAsset
)