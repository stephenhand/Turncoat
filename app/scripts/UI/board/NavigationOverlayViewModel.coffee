define(["underscore", "backbone", "ui/board/NominatedAssetOverlayViewModel"], (_, Backbone, NominatedAssetOverlayViewModel)->
  class NavigationOverlayViewModel extends NominatedAssetOverlayViewModel
    initialize:()->
      super()

    setAsset:(id)->
      super(id)
      @set('plannedActions', new Backbone.Collection())

    updatePreview:(x, y)->


  NavigationOverlayViewModel
)

