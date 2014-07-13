define(['underscore', 'backbone', 'lib/turncoat/GameStateModel', 'lib/turncoat/TypeRegistry', 'state/AssetPosition'], (_, Backbone, GameStateModel, TypeRegistry, AssetPosition)->
  class FleetAsset extends GameStateModel
    defaults:
      position:null

    getOwningPlayer:(game)->
      c = @getOwnershipChain(game)
      _.find(c, (ci)->ci instanceof TypeRegistry["Player"]) ? null

    getAvailableActions:()->
      @getRoot().getRuleBook()
        .lookUp("ships.permitted-actions")
        .getRule()
        .getPermittedActionsForAsset(@, @getRoot())


  FleetAsset.toString=()->
    "FleetAsset"

  TypeRegistry.registerType("FleetAsset", FleetAsset)


  FleetAsset
)