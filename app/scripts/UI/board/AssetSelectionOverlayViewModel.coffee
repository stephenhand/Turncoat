define(["underscore", "backbone", "UI/widgets/GameBoardViewModel", "UI/board/FleetAssetSelectionViewModel"], (_, Backbone, GameBoardViewModel, FleetAssetSelectionViewModel)->
  class AssetSelectionOverlayViewModel extends GameBoardViewModel
    initialize:()->
      super(null, modelType:FleetAssetSelectionViewModel)

    setNominatedAsset:(asset)->
      if (@get("nominatedAsset"))
        @get("nominatedAsset").unset("nominated")
        @unset("nominatedAsset")
      @set("nominatedAsset", asset)
      if (asset?) then asset.set("nominated", true)

  AssetSelectionOverlayViewModel
)

