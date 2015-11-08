define(["underscore", "backbone", "lib/turncoat/GameStateModel", "lib/turncoat/TypeRegistry", "state/AssetPosition"], (_, Backbone, GameStateModel, TypeRegistry, AssetPosition)->
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

    getCurrentTurnEvents:()->
      playerMoves = @getRoot().getCurrentTurnMoves()
      events = []
      for move in playerMoves
        for action in move.get("data").get("actions")?.models ? []

          events.push(event) for event in action.get("events")?.models ? [] when event.get("asset") is @get("id")
      events

    addContext:(context)->
      context.SHIP_LENGTH = @get("dimensions")?.get("length") ? 0


  FleetAsset.toString=()->
    "FleetAsset"

  FleetAsset.findByID = (game, id)->
    if !game? or !id? then throw new Error("Game and asset ID required")
    res = game.searchGameStateModels((gsm)->
      gsm instanceof FleetAsset and gsm.get("id") is id
    )
    if res.length>1 then throw new Error("ID clash! More than one asset with the same ID was found, this is an illegal state for game data to be in")
    res[0]


  TypeRegistry.registerType("FleetAsset", FleetAsset)


  FleetAsset
)