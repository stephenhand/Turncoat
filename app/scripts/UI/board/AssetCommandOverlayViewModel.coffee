define(["underscore", "backbone", "UI/widgets/GameBoardViewModel", "UI/FleetAsset2DViewModel"], (_, Backbone, GameBoardViewModel, FleetAsset2DViewModel)->
  class AssetCommandOverlayViewModel extends GameBoardViewModel
    initialize:()->
      super()
      @set("nominatedAssets", new Backbone.Collection())
    setGame:(game)->
      super(game)
      if game
        @getCommandsForAsset = (id, viewModel)->
          commands = new Backbone.Collection()
          action = game.getCurrentControllingPlayer().get("fleet").get(id).get("actions").at(0)
          if (action.get("types"))
            for actionType in action.get("types").models
              commands.push(
                target:viewModel
                label:actionType.get("name")
              )
          else
            commands.push(
              target:viewModel
              label:action.get("name")
            )
          commands.push(
            target:viewModel
            label:"Pass"
          )
          commands
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

