define(["underscore", "backbone", "UI/board/NominatedAssetOverlayViewModel", "UI/FleetAsset2DViewModel"], (_, Backbone, NominatedAssetOverlayViewModel, FleetAsset2DViewModel)->

  NAVIGATIONVIEW = "navigationView"
  TACTICALVIEW = "tacticalView"

  class AssetCommandOverlayViewModel extends NominatedAssetOverlayViewModel
    initialize:()->
      super()
      @set("nominatedAssets", new Backbone.Collection())
    setGame:(game)->
      super(game)
      that = @
      if game
        @getCommandsForAsset = (id, viewModel)->
          if !viewModel? then throw new Error("nominatedAssets must be set.")
          commands = game.getCurrentControllingPlayer().get("fleet").get(id).getAvailableActions()
          new Backbone.Collection(_.map(commands, (command)->
            overlay = null
            ret = null
            switch command.get("base")
              when "move"
                overlay = NAVIGATIONVIEW
              when "fire"
                overlay = TACTICALVIEW

            ret = new Backbone.Model(
              name:command.get("name")
              label:command.get("name")
              overlay:overlay
              target:viewModel
              select:()->
                that.set("selectedCommand", ret)
            )
            ret
          ))
      else
        delete @getCommandsForAsset

    setAsset:(id)->
      super(id)
      if id? then @set("commands", @getCommandsForAsset(id, @get("nominatedAssets").at(0)))


  AssetCommandOverlayViewModel
)

