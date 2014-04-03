define(["underscore", "backbone", "UI/component/ObservingViewModelCollection", "UI/FleetAsset2DViewModel", "state/FleetAsset"], (_, Backbone, ObservingViewModelCollection, FleetAsset2DViewModel, FleetAsset)->
  GameBoardViewModel = Backbone.Model.extend(
    initialize: (m, options)->
      @set("ships", new ObservingViewModelCollection())
      @assetType = options?.modelType ? FleetAsset2DViewModel
      @set("overlays", new Backbone.Collection())

    setGame:(game)->
      @get("ships").unwatch()
      if game?
        @get("ships").watch(
          game.searchChildren(
            (item)->
              (item instanceof Backbone.Collection) && item.find((collItem)->
                collItem instanceof FleetAsset
              )
          )
        )
        @get("ships").onSourceUpdated = ()=>
          @get("ships").updateFromWatchedCollections(
            (item, watchedItem)->
              item.get("modelId") is watchedItem.id
          ,
            (watchedItem)=>
              new @assetType(null, model:watchedItem)
          ,
            (watchedItem)->
              watchedItem instanceof FleetAsset
          )
        @get("ships").onSourceUpdated()
        overlay.setGame(game) for overlay in @get("overlays")?.models ? []
  )
)


