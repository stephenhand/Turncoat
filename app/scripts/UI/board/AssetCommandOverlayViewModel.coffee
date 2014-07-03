define(["underscore", "backbone", "UI/widgets/GameBoardViewModel", "UI/FleetAsset2DViewModel"], (_, Backbone, GameBoardViewModel, FleetAsset2DViewModel)->
  class AssetCommandOverlayViewModel extends GameBoardViewModel
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
        @set("commands", new Backbone.Collection([
            label:"Move",
             commands:new Backbone.Collection([
               label:"Oars",
               label:"Sail"
             ])
          ,
            label:"Fire"
          ]))

  AssetCommandOverlayViewModel
)

