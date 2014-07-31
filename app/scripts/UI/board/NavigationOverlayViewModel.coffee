define(["underscore", "backbone", "UI/board/NominatedAssetOverlayViewModel"], (_, Backbone, NominatedAssetOverlayViewModel)->
  class NavigationOverlayViewModel extends NominatedAssetOverlayViewModel
    initialize:()->
      super()

    setGame:(game)->
      super(game.ghost())

    setAsset:(id)->
      super(id)
      @set('plannedActions', new Backbone.Collection())

    updatePreview:(x, y)->


  NavigationOverlayViewModel
)

