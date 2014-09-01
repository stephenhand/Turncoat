define(['underscore', 'backbone', 'lib/turncoat/GameStateModel', 'lib/turncoat/TypeRegistry', 'state/AssetPosition'], (_, Backbone, GameStateModel, TypeRegistry, AssetPosition)->
  class FleetAsset extends GameStateModel
    defaults:
      position:null

    getOwningPlayer:()->
      c = @getOwnershipChain()
      _.find(c, (ci)->ci instanceof TypeRegistry["Player"]) ? null

    getAvailableActions:()->
      @getRoot().getRuleBook()
        .lookUp("ships.permitted-actions")
        .getActionRules()
        .getPermittedActionsForAsset(@, @getRoot())
    addContext:(context)->
      context.SHIP_LENGTH = @get("dimensions")?.get("length") ? 0


  FleetAsset.toString=()->
    "FleetAsset"

  TypeRegistry.registerType("FleetAsset", FleetAsset)


  FleetAsset
)