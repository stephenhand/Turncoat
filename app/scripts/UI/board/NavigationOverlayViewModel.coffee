define(["underscore", "backbone", "UI/board/NominatedAssetOverlayViewModel"], (_, Backbone, NominatedAssetOverlayViewModel)->
  class NavigationOverlayViewModel extends NominatedAssetOverlayViewModel
    initialize:()->
      super()

    setGame:(game)->
      super(game.ghost())

    setAsset:(id)->
      super(id)
      @set("plannedActions", new Backbone.Collection())

    setAction:(command)->
      @set("moveType", command.get("name"))

    updatePreview:(x, y)->
      if !@get("moveType")? then throw new Error("moveType must be set.")
      act = @getAsset().calculateClosestMoveAction(@get("moveType"), x,y)
      @set("queriedAction", act)


  NavigationOverlayViewModel
)

