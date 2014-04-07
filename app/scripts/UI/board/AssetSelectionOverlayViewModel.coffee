define(["underscore", "backbone", "UI/widgets/GameBoardViewModel", "UI/board/FleetAssetSelectionViewModel"], (_, Backbone, GameBoardViewModel, FleetAssetSelectionViewModel)->
  class AssetSelectionOverlayViewModel extends GameBoardViewModel
    initialize:()->
      super(null, modelType:FleetAssetSelectionViewModel)

  AssetSelectionOverlayViewModel
)

