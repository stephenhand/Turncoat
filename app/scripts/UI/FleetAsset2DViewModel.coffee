define(['underscore', 'backbone', 'AppState', 'UI/BaseViewModelItem'], (_, Backbone, AppState, BaseViewModelItem)->
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
        @set("classList", @get("classList")+" fleet-asset-2d")
        @updateFromFleetAsset()


    updateFromFleetAsset:()->
      models = AppState.get("game").state.searchGameStateModels((model)=>
        @get("modelId") is model.id
      )
      if (models.length)
        pos = models[0].get("position")
        @set("xpx",pos.get("x")+"px")
        @set("ypx",pos.get("y")+"px")
        @set("transformDegrees",pos.get("bearing"))

    #Executed in owner object context
    onModelUpdated:(model)->
      @updateFromFleetAsset()


  FleetAsset2DViewModel
)

