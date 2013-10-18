define(['underscore', 'backbone', 'AppState', 'UI/component/ObservingViewModelItem', 'UI/component/ObservingViewModelCollection', 'UI/FleetAsset2DViewModel', 'state/FleetAsset'], (_, Backbone, AppState, ObservingViewModelItem, ObservingViewModelCollection, FleetAsset2DViewModel, FleetAsset)->
  class PlayAreaViewModel extends ObservingViewModelItem
    initialize: (options)->
      super(options)
      appState = options?.appState
      appState?=AppState

      @watch(
        model:appState
        attributes:["game"]
      )
      @set("ships", new ObservingViewModelCollection())
      @onModelUpdated(appState)

    onModelUpdated:(model)=>
      if model.get("game")?
        @get("ships").watch(
          model.get("game").searchChildren(
            (item)->
              (item instanceof Backbone.Collection) && item.find((collItem)->
                collItem instanceof FleetAsset
              )
          )
        )
        @get("ships").updateFromWatchedCollections(
          (item, watchedItem)->
            item.get("modelId") is watchedItem.id
        ,
          (watchedItem)->
            new FleetAsset2DViewModel(model:watchedItem)
        ,
          (watchedItem)->
            watchedItem instanceof FleetAsset
        )
        @get("ships").onSourceUpdated = ()=>
          @get("ships").updateFromWatchedCollections(
            (item, watchedItem)->
              item.get("modelId") is watchedItem.id
          ,
            (watchedItem)->
              new FleetAsset2DViewModel(model:watchedItem)
          ,
            (watchedItem)->
              watchedItem instanceof FleetAsset
          )
      else
        @get("ships").unwatch()


  PlayAreaViewModel
)

