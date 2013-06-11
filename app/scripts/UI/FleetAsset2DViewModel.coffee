define(['underscore', 'backbone', 'UI/BaseViewModelItem', 'App'], (_, Backbone, BaseViewModelItem, App)->
  class FleetAsset2DViewModel extends BaseViewModelItem
    initialize:(options)->
      super(options)
      if (options?.model?)
        @watch([
          model:options.model
          attributes:[
            "position"
          ]
        ,
          model:options.model.get("position")
          attributes:[
            "x"
            "y"
            "bearing"
          ]
        ])
        @set("modelId", options.model.id)
        @set("classList", @get("classList")+" fleet-asset-2d"
        @updateFromFleetAsset())

    updateFromFleetAsset:()->
      model = App.gameState.searchGameStateModels((model)=>
        @get("modelId") is model.id
      )
      pos = model.get("position")

    #Executed in owner object context
    onModelUpdated:(model)->
      @updateFromFleetAsset()


  FleetAsset2DViewModel
)

