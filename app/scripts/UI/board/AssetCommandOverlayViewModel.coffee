define(["underscore", "backbone", "UI/widgets/GameBoardViewModel", "UI/FleetAsset2DViewModel"], (_, Backbone, GameBoardViewModel, FleetAsset2DViewModel)->
  class AssetCommandOverlayViewModel extends GameBoardViewModel
    initialize:()->
      super()
      @set("nominatedAssets", new Backbone.Collection())
    setGame:(game)->
      super(game)
      if game
        @getCommandsForAsset = (id, viewModel)->
          commands = game.getCurrentControllingPlayer().get("fleet").get(id).getAvailableActions()
          new Backbone.Collection(_.map(commands, (command)->
            name:command.get("name")
            label:command.get("name")
            target:viewModel
          ))
      else
        delete @getCommandsForAsset

    setAsset:(id)->
      if !id?
        @get("nominatedAssets").reset()
      else
        ship = @get("ships").findWhere(modelId:id)
        if !ship? then throw new Error("Nominated asset not found.")
        @get("nominatedAssets").set([ship])

        @set("commands", @getCommandsForAsset(id, ship))


  AssetCommandOverlayViewModel
)

