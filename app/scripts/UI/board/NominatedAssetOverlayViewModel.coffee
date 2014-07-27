define(["underscore", "backbone", "UI/widgets/GameBoardViewModel", "UI/FleetAsset2DViewModel"], (_, Backbone, GameBoardViewModel)->

  NAVIGATIONVIEW = "navigationView"
  TACTICALVIEW = "tacticalView"

  class NominatedAssetOverlayViewModel extends GameBoardViewModel
    initialize:()->
      super()
      @set("nominatedAssets", new Backbone.Collection())

    setAsset:(id)->
      if !id?
        @get("nominatedAssets").reset()
      else
        ship = @get("ships").findWhere(modelId:id)
        if !ship? then throw new Error("Nominated asset not found.")
        @get("nominatedAssets").set([ship])


  NominatedAssetOverlayViewModel
)

