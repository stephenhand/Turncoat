define(["underscore", "backbone", "UI/FleetAsset2DViewModel"], (_, Backbone, FleetAsset2DViewModel)->
  class FleetAssetSelectionViewModel extends FleetAsset2DViewModel
    initialize:(m, options)->
      super(m, options)
      @set("classList", @get("classList")+" asset-selection-highlight")
      @set("friendly", (options.game.getCurrentControllingPlayer() is options.model.getOwningPlayer(options.game)))

    select:()->


  FleetAssetSelectionViewModel
)

