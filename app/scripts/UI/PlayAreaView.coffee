define(['underscore', 'backbone', 'UI/BaseView', 'UI/component/ObservingViewModelCollection', 'UI/FleetAsset2DViewModel', 'state/FleetAsset', 'text!templates/PlayArea.html'], (_, Backbone, BaseView, BaseViewModelCollection, FleetAsset2DViewModel, FleetAsset, templateText)->
  class PlayAreaView extends BaseView
    initialize: (options)->
      options ?={}
      options.template = templateText
      options.rootSelector = "#playArea"
      super(options)

    createModel:()->
      ships = new BaseViewModelCollection()
      ships.watch(@gameState.searchChildren(
        (item)->
          (item instanceof Backbone.Collection) && item.find((collItem)->
            collItem instanceof FleetAsset
          )
        )
      )
      @model =
        ships:ships
      @model.ships.updateFromWatchedCollections(
        (item, watchedItem)->
          item.get("modelId") is watchedItem.id
        ,
        (watchedItem)->
          new FleetAsset2DViewModel(model:watchedItem)
        ,
        (watchedItem)->
          watchedItem instanceof FleetAsset
      )
      @model.ships.onSourceUpdated = ()=>
        @model.ships.updateFromWatchedCollections(
          (item, watchedItem)->
            item.get("modelId") is watchedItem.id
          ,
          (watchedItem)->
            new FleetAsset2DViewModel(model:watchedItem)
          ,
          (watchedItem)->
            watchedItem instanceof FleetAsset
        )




  PlayAreaView
)

